import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:appantibloqueo/core/providers/snow_provider.dart';
import 'package:appantibloqueo/core/notifications/notification_service.dart';
import 'package:appantibloqueo/features/auth/data/auth_service.dart';
import 'package:appantibloqueo/core/errors/firebase_error_mapper.dart';
import 'package:appantibloqueo/features/profile/data/user_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPassController = TextEditingController();
  final TextEditingController _recoveryEmailController =
      TextEditingController();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _aceptaPolitica1 = false;
  bool _aceptaPolitica2 = false;
  bool _aceptaPolitica3 = false;
  bool _loading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _loginEmailController.dispose();
    _loginPassController.dispose();
    _recoveryEmailController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Widget _buildTorchGif() {
    return SizedBox(
      width: 54,
      height: 90,
      child: Image.asset(
        'assets/images/torch.gif',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }

  Future<void> _confirmarAvisoNotificacionesYRegistrar() async {
    final continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Activar notificaciones'),
          content: const Text(
            'Para aprovechar todas las funciones de la app '
            '(avisos de noticias, playlist y comunicados), '
            'debes permitir las notificaciones del dispositivo. '
            'Podras cambiarlas mas tarde en Ajustes.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Entendido, continuar'),
            ),
          ],
        );
      },
    );

    if (continuar != true) return;
    final settings = await NotificationService.instance.requestUserPermission();
    final status = settings.authorizationStatus;
    final accepted = status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
    if (!accepted) {
      _showMessage(
        'Puedes registrarte igual, pero recuerda activar notificaciones en Ajustes.',
      );
    }
    await _registrarUsuario();
  }

  Future<void> _registrarUsuario() async {
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final correo = _correoController.text.trim().toLowerCase();
    final usuario = _userController.text.trim();
    final pass = _passController.text.trim();

    if (nombre.isEmpty ||
        apellidos.isEmpty ||
        correo.isEmpty ||
        usuario.isEmpty ||
        pass.isEmpty) {
      _showMessage('Todos los campos son obligatorios', isError: true);
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(correo)) {
      _showMessage('Correo inválido. Ejemplo: usuario@gmail.com',
          isError: true);
      return;
    }

    if (!_aceptaPolitica1 || !_aceptaPolitica2 || !_aceptaPolitica3) {
      _showMessage('Debes aceptar todas las políticas', isError: true);
      return;
    }

    if (pass.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres',
          isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final usernameAvailable =
          await _userRepository.isUsernameAvailable(usuario);
      if (!usernameAvailable) {
        _showMessage('El nombre de usuario ya existe', isError: true);
        return;
      }

      final credential = await _authService.registerWithEmailPassword(
        email: correo,
        password: pass,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw StateError('No se pudo obtener UID del usuario');
      }

      try {
        await _authService.savePendingRegistrationData(
          nombre: nombre,
          apellidos: apellidos,
          usuario: usuario,
        );
        await _authService.sendEmailVerification();
      } catch (e) {
        await _authService.deleteCurrentUser();
        await _authService.signOut();
        rethrow;
      }

      _showMessage(
          'Registro correcto. Revisa tu correo para verificar la cuenta.');
      _nombreController.clear();
      _apellidosController.clear();
      _correoController.clear();
      _userController.clear();
      _passController.clear();
      setState(() {
        _aceptaPolitica1 = false;
        _aceptaPolitica2 = false;
        _aceptaPolitica3 = false;
      });
      _pageController.jumpToPage(0);
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _iniciarSesion() async {
    final email = _loginEmailController.text.trim().toLowerCase();
    final pass = _loginPassController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMessage('Introduce correo y contraseña', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final credential = await _authService.loginWithEmailPassword(
        email: email,
        password: pass,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        final appUser = await _userRepository.getUser(uid);
        if (appUser != null && !appUser.isActive) {
          return;
        }
      }

      _showMessage('Sesión iniciada');
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _recuperarContrasena() async {
    final correo = _recoveryEmailController.text.trim().toLowerCase();
    if (correo.isEmpty) {
      _showMessage('Introduce un correo electrónico', isError: true);
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(correo)) {
      _showMessage('Correo inválido. Ejemplo: usuario@gmail.com',
          isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final isBlocked = await _userRepository.isRecoveryBlockedByEmail(correo);
      if (isBlocked) {
        _showMessage(
          'Esta cuenta está inhabilitada. Contacta con el administrador.',
          isError: true,
        );
        return;
      }

      await _authService.sendPasswordResetEmail(correo);
      _showMessage(
        'Si el correo existe y está habilitado, recibirás un email para restablecer la contraseña.',
      );
      _recoveryEmailController.clear();
      if (!mounted) return;
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage('No existe una cuenta con ese correo.', isError: true);
        return;
      }
      if (e.code == 'user-disabled') {
        _showMessage(
          'Esta cuenta está deshabilitada. Contacta con el administrador.',
          isError: true,
        );
        return;
      }
      _showMessage(FirebaseErrorMapper.fromAuth(e), isError: true);
    } catch (e) {
      _showMessage(FirebaseErrorMapper.fromObject(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _woodBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/tavern_wood_dark.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
        ),
        child: child,
      ),
    );
  }

  List<Shadow> _tavernShadows() => <Shadow>[
        Shadow(
          color: Colors.black.withValues(alpha: 0.9),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];

  TextStyle _tavernTitleStyle(BuildContext context) => TextStyle(
        fontFamily: 'Cinzel',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        color: const Color(0xFFF5E6C8),
        shadows: _tavernShadows(),
      );

  TextStyle _tavernBodyStyle(BuildContext context) => TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF5E6C8),
        shadows: _tavernShadows(),
      );

  TextStyle _tavernLinkStyle(BuildContext context) => TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        color: const Color(0xFFFFD08A),
        decoration: TextDecoration.underline,
        shadows: _tavernShadows(),
      );

  TextStyle _tavernFieldTextStyle(BuildContext context) => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  InputDecoration _tavernInputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: const Color(0xFFF5E6C8),
          fontWeight: FontWeight.w700,
          shadows: _tavernShadows(),
        ),
        floatingLabelStyle: TextStyle(
          color: const Color(0xFFFFD08A),
          fontWeight: FontWeight.w800,
          shadows: _tavernShadows(),
        ),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.45),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFB08A57).withValues(alpha: 0.85),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFFD08A),
            width: 2.0,
          ),
        ),
      );

  Widget _buildLoginPage() {
    return _woodBackground(
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 140,
                      decoration:
                          const BoxDecoration(color: Colors.transparent),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildTorchGif(),
                              const Spacer(),
                              Consumer<SnowProvider>(
                                builder: (context, snowProvider, _) {
                                  return IconButton(
                                    tooltip: snowProvider.isSnowing
                                        ? 'Quitar nieve'
                                        : 'Activar nieve',
                                    icon: Icon(
                                      Icons.ac_unit,
                                      color: snowProvider.isSnowing
                                          ? Colors.lightBlueAccent
                                          : Colors.white.withValues(alpha: 0.8),
                                      shadows: _tavernShadows(),
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      context.read<SnowProvider>().toggleSnow();
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildTorchGif(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, 60),
                      child: Center(
                        child: Image.asset(
                          'assets/images/buho_animado.gif',
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Iniciar Sesión',
                                style: _tavernTitleStyle(context)),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _loginEmailController,
                              style: _tavernFieldTextStyle(context),
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                                  _tavernInputDecoration('Correo electrónico'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _loginPassController,
                              obscureText: true,
                              style: _tavernFieldTextStyle(context),
                              decoration: _tavernInputDecoration('Contraseña'),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _loading ? null : _iniciarSesion,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 40),
                              ),
                              child: const Text('Entrar'),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              ),
                              child: Text(
                                '¿No tienes cuenta? Regístrate aquí',
                                style: _tavernLinkStyle(context),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _pageController.animateToPage(
                                2,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              ),
                              child: Text(
                                'Recuperar contraseña',
                                style: _tavernLinkStyle(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 60,
                        decoration:
                            const BoxDecoration(color: Colors.transparent)),
                  ],
                ),
              ),
            ),
          ),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x55000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegisterPage() {
    return _woodBackground(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 152,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _buildTorchGif(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Registro de Usuario',
                              style: _tavernTitleStyle(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildTorchGif(),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _nombreController,
                        style: _tavernFieldTextStyle(context),
                        decoration: _tavernInputDecoration('Nombre'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apellidosController,
                        style: _tavernFieldTextStyle(context),
                        decoration: _tavernInputDecoration('Apellidos'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _correoController,
                        style: _tavernFieldTextStyle(context),
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            _tavernInputDecoration('Correo electrónico'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _userController,
                        style: _tavernFieldTextStyle(context),
                        decoration: _tavernInputDecoration('Nombre de usuario'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        style: _tavernFieldTextStyle(context),
                        decoration: _tavernInputDecoration('Contraseña'),
                      ),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        title: Text('Acepto los Términos de servicio',
                            style: _tavernBodyStyle(context)),
                        value: _aceptaPolitica1,
                        onChanged: (val) =>
                            setState(() => _aceptaPolitica1 = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: Text('Acepto la Política de privacidad',
                            style: _tavernBodyStyle(context)),
                        value: _aceptaPolitica2,
                        onChanged: (val) =>
                            setState(() => _aceptaPolitica2 = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: Text('Acepto el Uso de cookies',
                            style: _tavernBodyStyle(context)),
                        value: _aceptaPolitica3,
                        onChanged: (val) =>
                            setState(() => _aceptaPolitica3 = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            _loading ? null : _confirmarAvisoNotificacionesYRegistrar,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40)),
                        child: const Text('Registrar'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                        child: Text('¿Ya tienes cuenta? Inicia sesión',
                            style: _tavernLinkStyle(context)),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  height: 60,
                  decoration: const BoxDecoration(color: Colors.transparent)),
            ],
          ),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x55000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecoveryPage() {
    return _woodBackground(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 152,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _buildTorchGif(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Recuperar Contraseña',
                              style: _tavernTitleStyle(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildTorchGif(),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Introduce tu correo y te enviaremos un email para restablecer la contraseña.',
                        textAlign: TextAlign.center,
                        style: _tavernBodyStyle(context),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _recoveryEmailController,
                        style: _tavernFieldTextStyle(context),
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            _tavernInputDecoration('Correo electrónico'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loading ? null : _recuperarContrasena,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text('Enviar recuperación'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                        child: Text('Volver a iniciar sesión',
                            style: _tavernLinkStyle(context)),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  height: 60,
                  decoration: const BoxDecoration(color: Colors.transparent)),
            ],
          ),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x55000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          _buildLoginPage(),
          _buildRegisterPage(),
          _buildRecoveryPage(),
        ],
      ),
    );
  }
}
