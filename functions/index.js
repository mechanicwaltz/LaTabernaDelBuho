"use strict";

const admin = require("firebase-admin");
const {logger} = require("firebase-functions");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onUserDeleted} = require("firebase-functions/v2/identity");

admin.initializeApp();

const DEFAULT_MAX_AGE_HOURS = 24;
const SCHEDULE_REGION = "europe-west1";
const SCHEDULE_TIME_ZONE = "Europe/Madrid";

function getMaxAgeHours() {
  const raw = process.env.UNVERIFIED_ACCOUNT_MAX_AGE_HOURS;
  const parsed = Number.parseInt(raw ?? "", 10);
  return Number.isFinite(parsed) && parsed > 0
    ? parsed
    : DEFAULT_MAX_AGE_HOURS;
}

function isOldEnough(metadata, nowMs, minAgeMs) {
  if (!metadata?.creationTime) return false;
  const createdAtMs = Date.parse(metadata.creationTime);
  if (Number.isNaN(createdAtMs)) return false;
  return nowMs - createdAtMs >= minAgeMs;
}

function hasEmailPasswordProvider(userRecord) {
  return (userRecord.providerData || []).some(
      (provider) => provider.providerId === "password",
  );
}

exports.cleanupUnverifiedAuthUsers = onSchedule(
    {
      schedule: "every 24 hours",
      timeZone: SCHEDULE_TIME_ZONE,
      region: SCHEDULE_REGION,
      memory: "256MiB",
      timeoutSeconds: 540,
    },
    async () => {
      const maxAgeHours = getMaxAgeHours();
      const maxAgeMs = maxAgeHours * 60 * 60 * 1000;
      const nowMs = Date.now();

      let scanned = 0;
      let deleted = 0;
      let skipped = 0;
      let nextPageToken;

      logger.info("Iniciando limpieza de cuentas no verificadas", {
        maxAgeHours,
      });

      do {
        const page = await admin.auth().listUsers(1000, nextPageToken);
        nextPageToken = page.pageToken;

        for (const user of page.users) {
          scanned += 1;

          // Solo limpia usuarios creados por email/password.
          if (!hasEmailPasswordProvider(user)) {
            skipped += 1;
            continue;
          }

          if (user.emailVerified) {
            skipped += 1;
            continue;
          }

          if (!isOldEnough(user.metadata, nowMs, maxAgeMs)) {
            skipped += 1;
            continue;
          }

          try {
            await admin.auth().deleteUser(user.uid);
            deleted += 1;
          } catch (error) {
            logger.error("No se pudo borrar usuario no verificado", {
              uid: user.uid,
              email: user.email ?? null,
              error: String(error),
            });
          }
        }
      } while (nextPageToken);

      logger.info("Limpieza finalizada", {
        scanned,
        deleted,
        skipped,
        maxAgeHours,
      });
    },
);

exports.cleanupFirestoreUserDataOnAuthDelete = onUserDeleted(
    {
      region: SCHEDULE_REGION,
    },
    async (event) => {
      const uid = event.data?.uid;
      if (!uid) return;

      const db = admin.firestore();
      const userRef = db.collection("users").doc(uid);

      try {
        await userRef.delete();
      } catch (error) {
        logger.warn("No se pudo borrar users/{uid} (puede no existir)", {
          uid,
          error: String(error),
        });
      }

      try {
        const aliases = await db.collection("usernames")
            .where("uid", "==", uid)
            .get();
        for (const doc of aliases.docs) {
          await doc.ref.delete();
        }
      } catch (error) {
        logger.error("Error limpiando usernames por uid", {
          uid,
          error: String(error),
        });
      }

      logger.info("Limpieza por borrado de Auth completada", {uid});
    },
);
