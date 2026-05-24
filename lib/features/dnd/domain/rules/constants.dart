// constants.dart

// ==========================
// ATRIBUTOS BASE
// ==========================
const List<String> baseAttributes = ['FUE', 'DES', 'CON', 'INT', 'SAB', 'CAR'];

// ==========================
// POINT BUY
// ==========================
const int pointBuyBudget = 27;
const Map<int, int> pointBuyCost = {
  8: 0,
  9: 1,
  10: 2,
  11: 3,
  12: 4,
  13: 5,
  14: 7,
  15: 9
};

// ==========================
// RAZAS Y SUBRAZAS
// ==========================
final Map<String, Map<String, dynamic>> races = {
  'Elfo': {
    'i':
        'Visión Oscura, Sentidos Agudos, Ascendencia feérica, Competencia en Espada Larga, Espada Corta, Arco Largo y Arco Corto.',
    'subraces': {
      'Alto elfo': 'i: Mayor Inteligencia y magia innata.',
      'Elfo de los bosques': 'i: Mayor Destreza, sigilo y percepción.',
      'Drow': 'i: Visión en la oscuridad superior y dominio en armas ligeras.'
    }
  },
  'Tiefling': {
    'i': 'Visión Oscura y Resistencia Infernal.',
    'subraces': {
      'Asmodeo': 'i: Afinidad con fuego y magia infernal.',
      'Mefistófeles': 'i: Mayor Carisma y habilidades sociales.',
      'Zariel': 'i: Mayor Fuerza y capacidades combativas.'
    }
  },
  'Drow': {
    'i':
        'Velocidad racial básica, Ascendencia feérica, visión oscura superior, dominio del estoque, espada corta y ballesta de mano.',
    'subraces': {
      'Drow adorador de Lolth': 'i: Foco en magia de sombras.',
      'Drow seraldine': 'i: Foco en combate cuerpo a cuerpo.'
    }
  },
  'Humano': {
    'i': 'Velocidad racial básica. +1 a todas las características.',
    'subraces': {}
  },
  'Githyanki': {
    'i':
        'Psiónico: Truco Mano de Mago, habilidad a elegir, Velocidad racial básica, Dominio de armadura ligera, armadura media, espada corta, espada larga y gran espada.',
    'subraces': {}
  },
  'Enano': {
    'i':
        'Visión Oscura, Resistencia Enana, Competencia en Hachas de Batalla, Hachas de Mano y Martillos.',
    'subraces': {
      'Enano de oro': 'i: Mayor Sabiduría y resistencia a magia.',
      'Enano escudo': 'i: Mayor Fuerza y habilidad defensiva.'
    }
  },
  'Semielfo': {
    'i': 'Ascendencia feérica y Visión Oscura.',
    'subraces': {
      'Alto semielfo': 'i: Mayor Inteligencia y habilidades mágicas.',
      'Semielfo de los bosques': 'i: Mayor Destreza y sigilo.',
      'Semielfo drow': 'i: Combinación de habilidades de los drow.'
    }
  },
  'Semiorco': {
    'i':
        'Velocidad Racial Básica, Visión Oscura, Resistencia Implacable, Amenazador, Ataques Salvajes.',
    'subraces': {}
  },
  'Mediano': {
    'i': 'Afortunado y Valiente.',
    'subraces': {
      'Piesligeros': 'i: Mayor sigilo y agilidad.',
      'Fortecor': 'i: Mayor resistencia y fuerza.'
    }
  },
  'Gnomo': {
    'i': 'Velocidad base y Astucia gnoma.',
    'subraces': {
      'Bosques': 'i: Sigilo y conexión con la naturaleza.',
      'Profundidades': 'i: Resistencia a magia.',
      'Rocas': 'i: Mayor fuerza física.'
    }
  },
  'Dracónido': {
    'i': 'Ascendencia dracónica y Velocidad racial básica.',
    'subraces': {
      'Dorado': 'i: Resistencia al fuego y ataque potente.',
      'Plateado': 'i: Resistencia al frío y habilidades defensivas.',
      'Rojo': 'i: Ataque de fuego.',
      'Azul': 'i: Ataque de rayo.',
      'Verde': 'i: Ataque venenoso.'
    }
  }
};

// ==========================
// RAZAS, SUBRAZAS, BONUS Y RASGOS
// ==========================
final Map<String, Map<String, int>> raceBonuses = {
  'Humano': {
    'FUE': 1,
    'DES': 1,
    'CON': 1,
    'INT': 1,
    'SAB': 1,
    'CAR': 1,
    'speed': 30
  },
  'Elfo': {'DES': 2, 'SAB': 1, 'speed': 30},
  'Enano': {'CON': 2, 'FOR': 1, 'speed': 25},
  'Mediano': {'DES': 2, 'CAR': 1, 'speed': 25},
  'Tiefling': {'INT': 1, 'CAR': 2, 'speed': 30},
  'Drow': {'DES': 2, 'INT': 1, 'speed': 30},
  'Semielfo': {'CAR': 2, 'INT': 1, 'DES': 1, 'speed': 30},
  'Semiorco': {'FUE': 2, 'CON': 1, 'speed': 30},
  'Gnomo': {'INT': 2, 'CON': 1, 'speed': 25},
  'Dracónido': {'FUE': 2, 'CAR': 1, 'speed': 30},
  'Githyanki': {'FUE': 2, 'DES': 1, 'speed': 30}
};

// ==========================
// DADOS DE GOLPE POR CLASE
// ==========================
final Map<String, int> classHitDie = {
  'Bárbaro': 12,
  'Bardo': 8,
  'Clérigo': 8,
  'Druida': 8,
  'Guerrero': 10,
  'Mago': 6,
  'Monje': 8,
  'Paladín': 10,
  'Pícaro': 8,
  'Hechicero': 6,
  'Explorador': 10,
  'Brujo': 8
};

// ==========================
// CLASES Y SUBCLASES
// ==========================
final Map<String, List<String>> subclasses = {
  'Bárbaro': [
    'Berserker',
    'Guerrero Totémico',
    'Magia Salvaje',
    'Camino de los Gigantes'
  ],
  'Bardo': [
    'Colegio del Valor',
    'Colegio del Conocimiento',
    'Colegio de las Espadas',
    'Colegio del Glamour'
  ],
  'Clérigo': [
    'Dominio de Conocimiento',
    'Dominio de Vida',
    'Dominio de Luz',
    'Dominio de Naturaleza',
    'Dominio de Tempestad',
    'Dominio del Engaño',
    'Dominio de Guerra',
    'Dominio de la Muerte'
  ],
  'Druida': [
    'Círculo de la Tierra',
    'Círculo de la Luna',
    'Círculo de las Esporas',
    'Círculo de las Estrellas'
  ],
  'Guerrero': [
    'Campeón',
    'Caballero Arcano',
    'Maestro de Batalla',
    'Arquero Arcano'
  ],
  'Monje': [
    'Camino de los Cuatro Elementos',
    'Camino de la Mano Abierta',
    'Camino de las Sombras',
    'Maestro Borracho'
  ],
  'Paladín': [
    'Rompejuramentos',
    'Juramento de Devoción',
    'Juramento de los Antiguos',
    'Juramento de Venganza',
    'Juramento de la Corona'
  ],
  'Explorador': [
    'Maestro de Bestias',
    'Cazador',
    'Acechador Oscuro',
    'Guardián de Enjambres'
  ],
  'Pícaro': ['Asesino', 'Bribón Arcano', 'Ladrón', 'Espadachín'],
  'Hechicero': [
    'Linaje de Sangre Dracónica',
    'Magia Salvaje',
    'Hechicería de la Tormenta',
    'Magia de las Sombras'
  ],
  'Brujo': ['Archihada', 'El Diablo', 'El Gran Antiguo', 'Espada Maldita'],
  'Mago': [
    'Escuela de Abjuración',
    'Conjuración',
    'Adivinación',
    'Encantamiento',
    'Evocación',
    'Nigromancia',
    'Ilusión',
    'Transmutación',
    'Espadas Mágicas'
  ]
};

// ==========================
// HABILIDADES POR CARACTERÍSTICA
// ==========================

final Map<String, Map<String, String>> skills = {
  // Fuerza
  'Atletismo': {
    'caracteristica': 'Fuerza',
    'i': 'Te ayuda a empujar y resistir empujones.'
  },

  // Destreza
  'Acrobacias': {
    'caracteristica': 'Destreza',
    'i': 'Te ayuda a resistir empujones y caer bien de pie.'
  },
  'Juego de manos': {
    'caracteristica': 'Destreza',
    'i': 'Te ayuda a forzar cerraduras, robar a la gente y desarmar trampas.'
  },
  'Sigilo': {'caracteristica': 'Destreza', 'i': 'Te ayuda a esconderte.'},

  // Inteligencia
  'Conocimiento arcano': {
    'caracteristica': 'Inteligencia',
    'i': 'Reconocer la magia e interactuar con objetos mágicos.'
  },
  'Historia': {
    'caracteristica': 'Inteligencia',
    'i': 'Recordar el pasado del mundo y su gente.'
  },
  'Investigación': {
    'caracteristica': 'Inteligencia',
    'i': 'Analizar pistas y resolver misterios.'
  },
  'Naturaleza': {
    'caracteristica': 'Inteligencia',
    'i': 'Reconocer plantas y animales.'
  },
  'Religión': {
    'caracteristica': 'Inteligencia',
    'i': 'Reconocer deidades. Comprender rituales sagrados.'
  },

  // Sabiduría
  'Trato con animales': {
    'caracteristica': 'Sabiduría',
    'i': 'Influenciar a los animales y acariciar a los perros.'
  },
  'Perspicacia': {
    'caracteristica': 'Sabiduría',
    'i': 'Juzgar a la gente y las situaciones. Detectar mentiras.'
  },
  'Medicina': {
    'caracteristica': 'Sabiduría',
    'i': 'Reconocer síntomas. Diagnosticar enfermedades.'
  },
  'Percepción': {
    'caracteristica': 'Sabiduría',
    'i': 'Observar el entorno, encontrar detalles ocultos.'
  },
  'Supervivencia': {
    'caracteristica': 'Sabiduría',
    'i': 'Sobrevivir en la naturaleza. Rastrear presa.'
  },

  // Carisma
  'Engaño': {
    'caracteristica': 'Carisma',
    'i': 'Mentir y engañar. Manipular la verdad.'
  },
  'Intimidación': {
    'caracteristica': 'Carisma',
    'i': 'Tener una actitud abusiva. Amenazar e infundir miedo.'
  },
  'Interpretación': {
    'caracteristica': 'Carisma',
    'i': 'Entretener al público. Estar en el centro del escenario.'
  },
  'Persuasión': {
    'caracteristica': 'Carisma',
    'i': 'Demostrar encanto. Persuadir y camelar.'
  },
};

// ==========================
// COMPETENCIAS DE CLASE
// ==========================
final Map<String, List<String>> classCompetencies = {
  'Bárbaro': ['FUE', 'CON'],
  'Bardo': ['CAR', 'DES'],
  'Clérigo': ['SAB'],
  'Druida': ['SAB', 'INT'],
  'Guerrero': ['FUE', 'CON'],
  'Mago': ['INT'],
  'Monje': ['DES', 'SAB'],
  'Paladín': ['FUE', 'CAR'],
  'Pícaro': ['DES'],
  'Hechicero': ['CAR'],
  'Explorador': ['DES', 'SAB'],
  'Brujo': ['CAR']
};

// ==========================
// COMPETENCIAS Y DOTES
// ==========================
final Map<String, String> allFeats = {
  'Mejora de característica':
      'i: Aumenta una puntuación de característica en 2, o dos puntuaciones en 1. Máx 20.',
  'Atleta':
      'i: Aumenta Fuerza o Destreza en 1. Menor gasto de movimiento al levantarse.',
  'Combatiente con Dos Armas':
      'i: Bonificador +1 CA si empuñas dos armas cuerpo a cuerpo.',
  'Con armadura ligera':
      'i: Competencia con armaduras ligeras. +1 Fuerza o Destreza (máx 20).',
  'Con armadura media':
      'i: Competencia con armaduras medias y escudos. +1 Fuerza y Destreza.',
  'Con armadura pesada': 'i: Competencia con armaduras pesadas. +1 Fuerza.',
  'Duelista Defensivo':
      'i: Usa reacción para aumentar CA ante ataques cuerpo a cuerpo.',
  'Duro': 'i: HP máximo +2 por nivel.',
  'Habilidoso': 'i: Competencia en tres habilidades a elección.',
  'Iniciado en la Magia':
      'i: Obtienes un conjuro de nivel 1 y dos trucos según clase.',
  'Maestro de Armas': 'i: +1 Fuerza o Destreza y competencia con 4 armas.',
  'Maestro en Armas Pesadas':
      'i: Ataque adicional en crítico con armas pesadas. Penalizador -5 al ataque, daño +10.',
  'Maestro en Escudos': 'i: +2 a tiradas de salvación de Destreza con escudo.',
  'Móvil': 'i: Aumenta velocidad y evita ataques de oportunidad tras atacar.',
  'Versado en las Armas':
      'i: Aprende maniobras de combate, recuperas dado de supremacía tras descanso corto o largo.'
};

// ==========================
// ARMAS
// ==========================
final Map<String, Map<String, String>> weapons = {
  'Daga': {
    'damage': '1d4 perforante',
    'i': 'Arma simple ligera de corto alcance.'
  },
  'Garrote': {'damage': '1d8 contundente', 'i': 'Arma simple contundente.'},
  'Hacha de mano': {
    'damage': '1d6 cortante',
    'i': 'Arma simple cuerpo a cuerpo.'
  },
  'Hoz': {'damage': '1d4 cortante', 'i': 'Arma simple corta.'},
  'Jabalina': {
    'damage': '1d6 perforante',
    'i': 'Arma de lanzamiento o cuerpo a cuerpo.'
  },
  'Lanza': {'damage': '1d6 perforante', 'i': 'Arma de alcance medio.'},
  'Martillo ligero': {
    'damage': '1d4 contundente',
    'i': 'Arma ligera de impacto.'
  },
  'Maza': {'damage': '1d6 contundente', 'i': 'Arma simple contundente.'},
  'Porra': {'damage': '1d4 contundente', 'i': 'Arma simple ligera.'},
  'Arco corto': {
    'damage': '1d6 perforante',
    'i': 'Arma a distancia de corto alcance.'
  },
  'Ballesta ligera': {
    'damage': '1d8 perforante',
    'i': 'Arma a distancia ligera y precisa.'
  },
  'Arco largo': {
    'damage': '1d8 perforante',
    'i': 'Arma a distancia de largo alcance.'
  },
  'Ballesta de mano': {
    'damage': '1d6 perforante',
    'i': 'Arma a distancia pequeña y rápida.'
  },
  'Ballesta pesada': {
    'damage': '1d10 perforante',
    'i': 'Arma a distancia de gran potencia.'
  },
  'Espada corta': {
    'damage': '1d6 perforante',
    'i': 'Arma cuerpo a cuerpo ligera y rápida.'
  },
  'Espada larga': {
    'damage': '1d8 cortante',
    'i': 'Arma cuerpo a cuerpo versátil.'
  },
  'Espadón': {
    'damage': '2d6 cortante',
    'i': 'Arma pesada de gran alcance y daño.'
  },
  'Estoque': {'damage': '1d8 perforante', 'i': 'Arma de estocada precisa.'},
  'Gran hacha': {'damage': '1d12 cortante', 'i': 'Arma pesada con gran daño.'},
  'Guja': {'damage': '1d10 cortante', 'i': 'Arma de asta larga y pesada.'},
  'Hacha de guerra': {'damage': '1d8 cortante', 'i': 'Arma marcial estándar.'},
  'Látigo': {'damage': '1d4 cortante', 'i': 'Arma flexible y versátil.'},
  'Lanza de caballería': {
    'damage': '1d12 perforante',
    'i': 'Arma para uso montado.'
  },
  'Lucero del alba': {
    'damage': '1d8 perforante',
    'i': 'Arma especial con propiedades mágicas.'
  },
  'Mangual': {'damage': '1d8 contundente', 'i': 'Arma de impacto pesado.'},
  'Martillo de guerra': {
    'damage': '1d8 contundente',
    'i': 'Arma cuerpo a cuerpo de combate.'
  },
  'Mazo': {'damage': '2d6 contundente', 'i': 'Arma pesada con daño alto.'},
  'Pica': {
    'damage': '1d10 perforante',
    'i': 'Arma larga para combate de formación.'
  },
  'Pico de cuervo': {
    'damage': '1d8 perforante',
    'i': 'Arma de ataque preciso.'
  },
  'Tridente': {
    'damage': '1d6 perforante',
    'i': 'Arma de lanza ligera y versátil.'
  }
};

// ==========================
// ARMADURAS
// ==========================
final Map<String, Map<String, dynamic>> armors = {
  'Acolchada': {
    'CA': '11 + DES',
    'FUE': 0,
    'sigilo': 'Desventaja',
    'i': 'Armadura ligera acolchada, buena defensa inicial.'
  },
  'Cuero': {
    'CA': '11 + DES',
    'FUE': 0,
    'sigilo': 'Normal',
    'i': 'Armadura ligera y flexible.'
  },
  'Cuero tachonado': {
    'CA': '12 + DES',
    'FUE': 0,
    'sigilo': 'Normal',
    'i': 'Armadura ligera con refuerzos metálicos.'
  },
  'Pieles': {
    'CA': '12 + DES (máx 2)',
    'FUE': 0,
    'sigilo': 'Normal',
    'i': 'Armadura media de protección moderada.'
  },
  'Camisote de malla': {
    'CA': '13 + DES (máx 2)',
    'FUE': 0,
    'sigilo': 'Normal',
    'i': 'Armadura media resistente.'
  },
  'Cota de escamas': {
    'CA': '14 + DES (máx 2)',
    'FUE': 0,
    'sigilo': 'Desventaja',
    'i': 'Armadura media reforzada.'
  },
  'Coraza': {
    'CA': '14 + DES (máx 2)',
    'FUE': 0,
    'sigilo': 'Normal',
    'i': 'Armadura media estándar.'
  },
  'Placas y malla': {
    'CA': '15 + DES (máx 2)',
    'FUE': 0,
    'sigilo': 'Desventaja',
    'i': 'Armadura pesada con buena defensa.'
  },
  'Cota de anillas': {
    'CA': '14',
    'FUE': 0,
    'sigilo': 'Desventaja',
    'i': 'Armadura pesada básica.'
  },
  'Cota de malla': {
    'CA': '16',
    'FUE': 13,
    'sigilo': 'Desventaja',
    'i': 'Armadura pesada estándar, requiere fuerza.'
  },
  'Laminada': {
    'CA': '17',
    'FUE': 15,
    'sigilo': 'Desventaja',
    'i': 'Armadura pesada avanzada.'
  },
  'Placas': {
    'CA': '18',
    'FUE': 15,
    'sigilo': 'Desventaja',
    'i': 'Armadura pesada máxima.'
  },
  'Escudo': {
    'CA': '+2',
    'FUE': 0,
    'sigilo': 'Normal',
    'i': 'Añade +2 a la CA al equipar.'
  }
};

// ==========================
// HECHIZOS HASTA NIVEL 6
// ==========================
final Map<String, Map<String, String>> allSpells = {
// Cantrips
  'Salpicadura de ácido': {
    'nivel': '0',
    'i': 'Proyecta ácido a un objetivo cercano, daño ácido 1d6.'
  },
  'Sala de la hoja': {
    'nivel': '0',
    'i': 'Corta a un enemigo con energía mágica de hoja, daño cortante 1d8.'
  },
  'Enfriamiento de hueso': {
    'nivel': '0',
    'i': 'Ataque mágico que inflige daño necrótico 1d6.'
  },
  'Hoja de auge': {
    'nivel': '0',
    'i': 'Cuchilla mágica que inflige daño cortante 1d8.'
  },
  'Serpiendo Sinew': {
    'nivel': '0',
    'i': 'Manipula energía mágica para daño y control de enemigo, 1d6.'
  },
  'Luces de baile': {
    'nivel': '0',
    'i': 'Crea luces flotantes para iluminar o distraer.'
  },
  'Perno de hechizo': {
    'nivel': '0',
    'i': 'Rayo de energía que inflige daño de fuerza 1d10.'
  },
  'Amigos': {
    'nivel': '0',
    'i': 'Mejora temporalmente las relaciones sociales.'
  },
  'Guía': {'nivel': '0', 'i': 'Aumenta 1d4 a tirada de ataque o habilidad.'},
  'Luz': {'nivel': '0', 'i': 'Ilumina un objeto, útil en oscuridad.'},
  'Mano de Mago': {
    'nivel': '0',
    'i': 'Crea mano espectral para manipular objetos a distancia.'
  },
  'Ilusión menor': {
    'nivel': '0',
    'i': 'Crea ilusión simple para distraer o engañar.'
  },
  'Spray de veneno': {
    'nivel': '0',
    'i': 'Ataque que inflige daño venenoso 1d12.'
  },
  'Produce Llama': {
    'nivel': '0',
    'i': 'Crea llama mágica en la mano, daño fuego 1d8.'
  },
  'Rayo de Escarcha': {
    'nivel': '0',
    'i': 'Rayo frío, daño 1d8 y ralentiza al enemigo.'
  },
  'Resistencia': {
    'nivel': '0',
    'i': 'Proporciona ventaja en tirada de salvación de una característica.'
  },
  'Llama Sagrada': {
    'nivel': '0',
    'i': 'Daño radiante 1d8 a un enemigo que elijas.'
  },
  'Shillelagh': {
    'nivel': '0',
    'i': 'Mejora bastón o garrote, usando INT o SAB para ataque y daño.'
  },
  'Agarre impresionante': {
    'nivel': '0',
    'i': 'Causa daño de fuerza y puede inmovilizar.'
  },
  'Thaumaturgy': {
    'nivel': '0',
    'i': 'Efectos menores para asustar o impresionar.'
  },
  'Látigo de espina': {
    'nivel': '0',
    'i': 'Daño cortante a distancia 1d6, alcance 10 pies.'
  },
  'Toll the Dead': {
    'nivel': '0',
    'i': 'Daño necrotico 1d8/1d12 si objetivo no está al máximo de HP.'
  },
  'Golpe verdadero': {
    'nivel': '0',
    'i':
        'Ataque que concede ventaja en siguiente ataque a distancia o cuerpo a cuerpo.'
  },
  'Burlaciosa viciosa': {
    'nivel': '0',
    'i': 'Ataque de truco para molestar o distraer, sin daño.'
  },

// Nivel 1
  'Amistad de los animales': {
    'nivel': '1',
    'i': 'Ganas la amistad de bestias para asistir, duración 24 horas.'
  },
  'Armadura de Agathys': {
    'nivel': '1',
    'i': 'Otorga puntos de golpe temporales y daña atacantes cuerpo a cuerpo.'
  },
  'Armas de Hadar': {
    'nivel': '1',
    'i': 'Energía oscura que inflige daño necrótico a enemigos cercanos.'
  },
  'Maldición': {
    'nivel': '1',
    'i': 'Reduce tiradas de ataque y salvación de un enemigo.'
  },
  'Bendición': {
    'nivel': '1',
    'i': 'Bonificador 1d4 a tiradas de ataque o salvación para aliados.'
  },
  'Manos ardientes': {
    'nivel': '1',
    'i': 'Cono de fuego 15 pies, tirada de salvación de Destreza reduce daño.'
  },
  'Encantar persona': {
    'nivel': '1',
    'i': 'Fascina un humanoide, falla salvación de Sabiduría.'
  },
  'Orbe cromático': {
    'nivel': '1',
    'i': 'Orbe de daño elemental a elección, tirada de ataque de hechizo.'
  },
  'Spray de color': {
    'nivel': '1',
    'i':
        'Cegamiento temporal de enemigos en área, tirada de salvación de Constitución.'
  },
  'Comando': {
    'nivel': '1',
    'i':
        'Ordena una acción simple a un enemigo que falle salvación de Sabiduría.'
  },
  'Duelo obligado': {
    'nivel': '1',
    'i':
        'Obliga a un enemigo a atacarte a ti, tirada de salvación de Sabiduría.'
  },
  'Crear o destruir agua': {
    'nivel': '1',
    'i': 'Genera o elimina agua en un área pequeña.'
  },
  'Curar heridas': {
    'nivel': '1',
    'i': 'Recupera puntos de golpe a un objetivo.'
  },
  'Disfrazarse': {'nivel': '1', 'i': 'Cambia apariencia física del lanzador.'},
  'Susurros disonantes': {
    'nivel': '1',
    'i':
        'Daño psíquico y obliga a moverse lejos del lanzador, salvación de Sabiduría.'
  },
  'Favor divino': {
    'nivel': '1',
    'i': 'Ataque cuerpo a cuerpo gana daño radiante adicional.'
  },
  'Mejorar salto': {
    'nivel': '1',
    'i': 'Aumenta distancia de salto del objetivo.'
  },
  'Golpe atrapante': {
    'nivel': '1',
    'i': 'Ataque que puede empujar y limitar movimiento del enemigo.'
  },
  'Enredar': {
    'nivel': '1',
    'i':
        'Área de terreno dificultoso que inmoviliza enemigos que fallen salvación de Fuerza.'
  },
  'Retirada rápida': {
    'nivel': '1',
    'i': 'Permite moverse adicional sin provocar ataques de oportunidad.'
  },
  'Fuego de hada': {
    'nivel': '1',
    'i': 'Marca enemigos con luz que da ventaja a ataques contra ellos.'
  },
  'Vida falsa': {'nivel': '1', 'i': 'Otorga puntos de golpe temporales.'},
  'Caída de pluma': {'nivel': '1', 'i': 'Caída lenta, evita daño por caída.'},
  'Encuentra familiar': {
    'nivel': '1',
    'i': 'Invoca un familiar para asistencia, exploración o combate.'
  },
  'Nube de niebla': {
    'nivel': '1',
    'i': 'Área de niebla que bloquea visión y dificultar movimientos.'
  },
  'Bayas buenas': {
    'nivel': '1',
    'i': 'Cura 1 punto de golpe y proporciona alimento.'
  },
  'Perno guía': {
    'nivel': '1',
    'i': 'Daño radiante y ventaja en siguiente ataque contra objetivo.'
  },
  'Saludo de espinas': {
    'nivel': '1',
    'i':
        'Causa daño adicional a enemigos cercanos al atacar a un objetivo marcado.'
  },
  'Palabra de curación': {
    'nivel': '1',
    'i': 'Cura rápida a objetivo aliado a distancia.'
  },
  'Reprimenda infernal': {
    'nivel': '1',
    'i': 'Daño fuego a criatura que falle tirada de salvación de Destreza.'
  },
  'Heroísmo': {
    'nivel': '1',
    'i': 'Otorga temporalmente puntos de golpe y inmunidad a miedo.'
  },
  'Hex': {
    'nivel': '1',
    'i': 'Marca objetivo, daño adicional y penaliza tiradas de habilidad.'
  },
  'Marca del cazador': {
    'nivel': '1',
    'i': 'Marca un objetivo, daño adicional al atacarlo.'
  },
  'Cuchillo de hielo': {
    'nivel': '1',
    'i': 'Ataque de proyectil de hielo, daño cortante o perforante.'
  },
  'Infligir heridas': {'nivel': '1', 'i': 'Daño necrótico a un objetivo.'},
  'Pasolargo': {
    'nivel': '1',
    'i': 'Aumenta velocidad de objetivo temporalmente.'
  },
  'Armadura de mago': {
    'nivel': '1',
    'i': 'Aumenta CA del objetivo temporalmente.'
  },
  'Misil mágico': {
    'nivel': '1',
    'i': 'Impacta automáticamente al objetivo, daño mágico 1d4+1 por proyectil.'
  },
  'Protección contra el mal y el bien': {
    'nivel': '1',
    'i': 'Otorga ventaja contra ciertas criaturas y protección de efectos.'
  },
  'Rayo de enfermedad': {
    'nivel': '1',
    'i': 'Inflige daño necrótico y puede enfermar al objetivo.'
  },
  'Santuario': {
    'nivel': '1',
    'i': 'Otorga ventaja a salvaciones de objetivo y lo protege de ataques.'
  },
  'Smite abrasador': {
    'nivel': '1',
    'i': 'Ataque cuerpo a cuerpo que inflige daño radiante adicional.'
  },
  'Escudo': {'nivel': '1', 'i': 'Reacción que aumenta CA temporalmente.'},
  'Escudo de la fe': {
    'nivel': '1',
    'i': 'Otorga +2 CA a un aliado durante la concentración.'
  },
  'Dormir': {
    'nivel': '1',
    'i':
        'Pone a dormir a enemigos en área, tirada de salvación de Constitución.'
  },
  'Hablar con animales': {
    'nivel': '1',
    'i': 'Permite comunicarse con animales.'
  },
  'Risa horrible de Tasha': {
    'nivel': '1',
    'i':
        'Causa que enemigo caiga al suelo, incapacitado si falla salvación de Sabiduría.'
  },
  'Estrillo atronador': {
    'nivel': '1',
    'i': 'Daño sónica y empuja enemigos, tirada de salvación de Constitución.'
  },
  'Onda de trueno': {
    'nivel': '1',
    'i': 'Empuja y daña a enemigos en área con sonido potente.'
  },
  'Perno de bruja': {
    'nivel': '1',
    'i': 'Daño eléctrico a un objetivo a distancia.'
  },
  'Smite iracundo': {
    'nivel': '1',
    'i':
        'Ataque que inflige daño radiante adicional y puede asustar al enemigo.'
  },

// Nivel 2
  'Ayuda': {
    'nivel': '2',
    'i':
        'Aumenta puntos de golpe temporales a aliados y mejora tiradas de ataque.'
  },
  'Cerradura arcana': {
    'nivel': '2',
    'i':
        'Bloquea una puerta u objeto con magia, requiere INT o Sabiduría para abrir.'
  },
  'Piel de corteza': {
    'nivel': '2',
    'i': 'Aumenta CA a un objetivo, duración concentrada.'
  },
  'Ceguera': {
    'nivel': '2',
    'i': 'Ciega a un objetivo si falla salvación de Constitución.'
  },
  'Desenfoque': {
    'nivel': '2',
    'i': 'Difumina imagen del objetivo, dificultad para acertarle.'
  },
  'Golpe de marca': {
    'nivel': '2',
    'i': 'Daño adicional y efectos especiales sobre objetivo al golpear.'
  },
  'Calmar emociones': {
    'nivel': '2',
    'i': 'Aplaca hostilidades, enemigos fallan tirada de salvación de Carisma.'
  },
  'Nube de dagas': {
    'nivel': '2',
    'i':
        'Daño cortante a todos en área, tirada de salvación de Destreza reduce daño.'
  },
  'Corona de locura': {
    'nivel': '2',
    'i': 'Controla enemigo para atacar a otros si falla salvación de Sabiduría.'
  },
  'Oscuridad': {
    'nivel': '2',
    'i': 'Bloquea visión en área, criaturas oscuras no ven.'
  },
  'Visión en la oscuridad': {
    'nivel': '2',
    'i': 'Otorga visión en la oscuridad superior a un objetivo.'
  },
  'Detectar pensamientos': {
    'nivel': '2',
    'i':
        'Leer pensamientos superficiales de un objetivo, salvación de Sabiduría permite resistir.'
  },
  'Mejorar habilidad': {
    'nivel': '2',
    'i': 'Bonifica temporalmente característica del objetivo.'
  },
  'Ampliar/Reducir': {
    'nivel': '2',
    'i': 'Cambia tamaño de criatura u objeto temporalmente.'
  },
  'Enredadera': {'nivel': '2', 'i': 'Ataca enemigos con vinagretes mágicos.'},
  'Hoja de llama': {
    'nivel': '2',
    'i': 'Daño fuego a un enemigo, puede atacar cuerpo a cuerpo.'
  },
  'Esfera flamígera': {
    'nivel': '2',
    'i': 'Esfera de fuego que se mueve causando daño a enemigos cercanos.'
  },
  'Ráfaga de viento': {
    'nivel': '2',
    'i': 'Empuja enemigos, afecta proyectiles ligeros.'
  },
  'Metal caliente': {
    'nivel': '2',
    'i': 'Inflige daño y debilita armadura metálica de objetivo.'
  },
  'Parar persona': {
    'nivel': '2',
    'i': 'Inmoviliza a humanoide que falle tirada de salvación de Sabiduría.'
  },
  'Invisibilidad': {
    'nivel': '2',
    'i': 'Vuelve invisible al objetivo hasta atacar o realizar acción.'
  },
  'Llamada': {'nivel': '2', 'i': 'Abre puerta cerrada mágicamente.'},
  'Restauración menor': {
    'nivel': '2',
    'i': 'Elimina condición de parálisis, veneno o enfermedad menor.'
  },
  'Arma mágica': {
    'nivel': '2',
    'i': 'Convierte arma normal en mágica, mejora ataques.'
  },
  'Flecha ácida de Melf': {
    'nivel': '2',
    'i': 'Dispara flecha que inflige daño ácido 2d4 en impacto.'
  },
  'Imagen espejo': {
    'nivel': '2',
    'i': 'Crea duplicados ilusorios para desviar ataques.'
  },
  'Paso brumoso': {
    'nivel': '2',
    'i': 'Teletransporte a corta distancia de manera instantánea.'
  },
  'Rastro sin huella': {
    'nivel': '2',
    'i': 'Otorga sigilo y no deja rastro en terreno natural.'
  },
  'Oración de sanación': {
    'nivel': '2',
    'i': 'Cura múltiple de puntos de golpe a aliados cercanos.'
  },
  'Protección contra veneno': {
    'nivel': '2',
    'i':
        'Otorga ventaja en tiradas de salvación contra veneno y resistencia a daño de veneno.'
  },
  'Rayo debilitante': {
    'nivel': '2',
    'i': 'Inflige daño y penaliza fuerza o ataque de objetivo.'
  },
  'Rayo abrasador': {
    'nivel': '2',
    'i':
        'Dispara tres rayos de fuego a objetivos diferentes, tirada de ataque de hechizo.'
  },
  'Ver invisibilidad': {
    'nivel': '2',
    'i': 'Permite ver criaturas invisibles o mágicamente ocultas.'
  },
  'Hoja de sombras': {
    'nivel': '2',
    'i': 'Crea arma mágica de energía sombría que inflige daño cortante.'
  },
  'Fragmentar': {
    'nivel': '2',
    'i': 'Causa daño contundente en área a objetos y enemigos.'
  },
  'Silencio': {
    'nivel': '2',
    'i':
        'Área donde no se puede emitir sonido ni lanzar conjuros con componentes verbales.'
  },
  'Crecimiento de espinas': {
    'nivel': '2',
    'i': 'Daña y ralentiza enemigos en área de espinas mágicas.'
  },
  'Arma espiritual': {
    'nivel': '2',
    'i': 'Invoca arma mágica que ataca independientemente al objetivo.'
  },
  'Vínculo de protección': {
    'nivel': '2',
    'i': 'Une un aliado a tí, comparte daño recibido.'
  },
  'Telaraña': {
    'nivel': '2',
    'i': 'Inmoviliza enemigos atrapados en la telaraña mágica.'
  },

// Nivel 3
  'Animar muertos': {
    'nivel': '3',
    'i': 'Reanima esqueletos o zombis bajo tu control, duración concentrada.'
  },
  'Baliza de esperanza': {
    'nivel': '3',
    'i':
        'Otorga ventaja en tiradas de salvación y cura máxima de golpe a aliados cercanos.'
  },
  'Conceder maldición': {
    'nivel': '3',
    'i':
        'Aplica un efecto negativo a objetivo: penaliza ataques, salvaciones o daño extra.'
  },
  'Cegamiento/Deslumbramiento': {
    'nivel': '3',
    'i': 'Ciega a un objetivo que falle tirada de salvación de Constitución.'
  },
  'Parpadear': {
    'nivel': '3',
    'i': 'Teletransportación aleatoria breve al final de tu turno.'
  },
  'Llamar relámpago': {
    'nivel': '3',
    'i':
        'Convoca un rayo que inflige daño de relámpago en área, tirada de salvación de Destreza para mitad.'
  },
  'Barrage conjurado': {
    'nivel': '3',
    'i': 'Ataque en línea o área con múltiples proyectiles mágicos.'
  },
  'Contraconjuro': {
    'nivel': '3',
    'i':
        'Interrumpe hechizo de un objetivo mientras se lanza, tirada de reacción.'
  },
  'Manto del cruzado': {
    'nivel': '3',
    'i':
        'Aliados cercanos infligen daño radiante extra mientras permanecen en área.'
  },
  'Luz del día': {
    'nivel': '3',
    'i': 'Crea esfera de luz intensa que ciega enemigos y da ventaja a aliados.'
  },
  'Arma elemental': {
    'nivel': '3',
    'i':
        'Crea un arma mágica de energía elemental a elección, dura concentrada.'
  },
  'Miedo': {
    'nivel': '3',
    'i': 'Enemigos huyen si fallan tirada de salvación de Sabiduría.'
  },
  'Muerte fingida': {
    'nivel': '3',
    'i': 'Objetivo parece muerto, suspensión temporal de funciones vitales.'
  },
  'Bola de fuego': {
    'nivel': '3',
    'i':
        'Explosión de fuego 20 pies de radio, tirada de salvación de Destreza para mitad de daño.'
  },
  'Forma gaseosa': {
    'nivel': '3',
    'i': 'Convierte a objetivo o a ti en nube de gas, movilidad aumentada.'
  },
  'Glifo de protección': {
    'nivel': '3',
    'i': 'Crea trampa mágica que explota al activarse, daño variable.'
  },
  'Vuelo': {
    'nivel': '3',
    'i': 'Otorga velocidad de vuelo a objetivo, duración concentrada.'
  },
  'Prisa': {
    'nivel': '3',
    'i':
        'Aumenta velocidad y número de acciones por turno de aliados, duración concentrada.'
  },
  'Hambre de Hadar': {
    'nivel': '3',
    'i':
        'Área de oscuridad mágica que inflige daño necrótico a enemigos cercanos.'
  },
  'Patrón hipnótico': {
    'nivel': '3',
    'i':
        'Fascina y paraliza enemigos en área si fallan tirada de salvación de Sabiduría.'
  },
  'Flecha de relámpago': {
    'nivel': '3',
    'i': 'Dispara un proyectil de electricidad que inflige daño a objetivo.'
  },
  'Rayo de relámpago': {
    'nivel': '3',
    'i':
        'Rayo de electricidad en línea recta, tirada de salvación de Destreza para mitad.'
  },
  'Palabra de curación masiva': {
    'nivel': '3',
    'i': 'Cura puntos de golpe a varios aliados en área.'
  },
  'Crecimiento de plantas': {
    'nivel': '3',
    'i': 'Mejora plantas o terreno, puede ralentizar o bloquear enemigos.'
  },
  'Protección contra energía': {
    'nivel': '3',
    'i':
        'Resistencia a un tipo de daño elemental a objetivo, duración concentrada.'
  },
  'Eliminar maldición': {
    'nivel': '3',
    'i': 'Quita maldiciones de objetivo o área.'
  },
  'Revivir': {
    'nivel': '3',
    'i': 'Resucita criatura muerta recientemente con 1 punto de golpe.'
  },
  'Tormenta de aguanieve': {
    'nivel': '3',
    'i': 'Causa daño frío y ralentiza enemigos en área de 20 pies.'
  },
  'Lento': {
    'nivel': '3',
    'i':
        'Reduce velocidad y número de acciones de enemigos que fallan tirada de salvación de Sabiduría.'
  },
  'Hablar con muertos': {
    'nivel': '3',
    'i': 'Permite hacer preguntas a cadáveres recientes, respuestas limitadas.'
  },
  'Guardianes espirituales': {
    'nivel': '3',
    'i':
        'Invoca guardianes que infligen daño radiante a enemigos cercanos, duración concentrada.'
  },

// Nivel 4
  'Destierro': {
    'nivel': '4',
    'i':
        'Expulsa objetivo a plano extradimensional si falla salvación de Carisma.'
  },
  'Marchitamiento': {
    'nivel': '4',
    'i': 'Daño necrótico a plantas o criaturas vegetales y humanoides.'
  },
  'Confusión': {
    'nivel': '4',
    'i':
        'Objetos o criaturas atacan aleatoriamente si fallan salvación de Sabiduría.'
  },
  'Invocar elemental menor': {
    'nivel': '4',
    'i': 'Invoca elemental de nivel bajo bajo tu control durante concentración.'
  },
  'Invocar criatura del bosque': {
    'nivel': '4',
    'i': 'Invoca criatura fey para asistir en combate o exploración.'
  },
  'Sala de la muerte': {
    'nivel': '4',
    'i':
        'Área de daño necrótico elevado, tirada de salvación de Constitución para mitad.'
  },
  'Puerta dimensional': {
    'nivel': '4',
    'i': 'Crea portal entre dos puntos, transporte instantáneo.'
  },
  'Dominar bestia': {
    'nivel': '4',
    'i': 'Controla mente de criatura no humanoide, duración concentrada.'
  },
  'Tentáculos negros de Evard': {
    'nivel': '4',
    'i':
        'Causa daño contundente y restricción de movimiento en área de 20 pies.'
  },
  'Escudo de fuego': {
    'nivel': '4',
    'i': 'Área de fuego que daña a enemigos y protege al lanzador.'
  },
  'Libertad de movimiento': {
    'nivel': '4',
    'i':
        'Objetivo puede moverse sin impedimentos mágicos o físicos, duración concentrada.'
  },
  'Vid de agarre': {
    'nivel': '4',
    'i': 'Controlas vid que inmoviliza enemigos en área, daño leve.'
  },
  'Invisibilidad superior': {
    'nivel': '4',
    'i': 'Vuelve invisible a un objetivo hasta que ataque o lance hechizo.'
  },
  'Guardián de la fe': {
    'nivel': '4',
    'i':
        'Crea área mágica que inflige daño radiante a enemigos que entren en ella.'
  },
  'Tormenta de hielo': {
    'nivel': '4',
    'i':
        'Daño frío en área y ralentiza enemigos, tirada de salvación de Constitución para mitad.'
  },
  'Esfera resiliente de Otiluke': {
    'nivel': '4',
    'i': 'Esfera de fuerza que protege a aliados y bloquea ataques.'
  },
  'Asesino fantasmal': {
    'nivel': '4',
    'i':
        'Inflige daño adicional a enemigos desprevenidos, crea ilusión fantasmagórica.'
  },
  'Polimorfo': {
    'nivel': '4',
    'i':
        'Convierte objetivo en criatura pequeña o inofensiva temporalmente, tirada de salvación de Constitución.'
  },
  'Smite escalofriante': {
    'nivel': '4',
    'i':
        'Ataque cuerpo a cuerpo inflige daño radiante adicional y asusta objetivo.'
  },
  'Piel de piedra': {
    'nivel': '4',
    'i': 'Aumenta CA y resistencia a daño de objetivo concentrando hechizo.'
  },
  'Muro de fuego': {
    'nivel': '4',
    'i': 'Crea muro de fuego que inflige daño a los que lo atraviesen.'
  },

// Nivel 5
  'Desterrar Smite': {
    'nivel': '5',
    'i': 'Expulsa objetivo extraplanar y causa daño radiante.'
  },
  'Nube mortal': {
    'nivel': '5',
    'i': 'Área de gas venenoso que inflige daño y ceguera temporal.'
  },
  'Cono de frío': {
    'nivel': '5',
    'i': 'Cono de frío intenso que inflige daño contundente y reduce velocidad.'
  },
  'Invocar elemental': {
    'nivel': '5',
    'i': 'Invoca elemental potente bajo tu control concentrado.'
  },
  'Contagio': {
    'nivel': '5',
    'i':
        'Inflige enfermedad que daña y penaliza tiradas de habilidad, salvación de Constitución para resistir.'
  },
  'Arteria de guerra': {
    'nivel': '5',
    'i':
        'Habilidad especial de combate, inflige daño en área y controla enemigos.'
  },
  'Onda destructiva': {
    'nivel': '5',
    'i':
        'Onda expansiva que inflige daño contundente a todos los enemigos en línea.'
  },
  'Destronar': {
    'nivel': '5',
    'i':
        'Fuerza objetivo a caer y perder posición, salvación de Sabiduría para resistir.'
  },
  'Disipar el mal y el bien': {
    'nivel': '5',
    'i':
        'Elimina efectos mágicos de área o criatura, incluyendo bendiciones y maldiciones.'
  },
  'Persona dominada': {
    'nivel': '5',
    'i': 'Controla mente de objetivo humanoide durante concentración.'
  },
  'Golpe de llama': {
    'nivel': '5',
    'i': 'Ataque de fuego a un objetivo que inflige daño adicional por turno.'
  },
  'Restauración mayor': {
    'nivel': '5',
    'i': 'Cura condiciones graves o devuelve características perdidas.'
  },
  'Atrapar monstruo': {
    'nivel': '5',
    'i':
        'Inmoviliza objetivo poderoso, tirada de salvación de Sabiduría para resistir.'
  },
  'Plaga de insectos': {
    'nivel': '5',
    'i': 'Área infestada que causa daño y penaliza movimientos.'
  },
  'Heridas de curación masiva': {
    'nivel': '5',
    'i': 'Cura grande a múltiples aliados en área.'
  },
  'Encuadernación plana': {
    'nivel': '5',
    'i':
        'Ataque mágico que paraliza objetivo, daño adicional si falla salvación.'
  },
  'Aparente': {
    'nivel': '5',
    'i': 'Cambia apariencia de un objetivo o criatura de manera convincente.'
  },
  'Telequinesis': {
    'nivel': '5',
    'i': 'Mueve o inmoviliza objetos y criaturas a distancia con fuerza mental.'
  },
  'Muro de piedra': {
    'nivel': '5',
    'i': 'Crea muro sólido que bloquea movimientos y ataques.'
  },

// Nivel 6
  'Portal Arcano': {
    'nivel': '6',
    'i':
        'Crea portales mágicos que permiten viajar instantáneamente entre dos puntos visibles.'
  },
  'Barrera de Cuchillas': {
    'nivel': '6',
    'i':
        'Muro de cuchillas flotantes que inflige 6d10 daño cortante a quienes lo atraviesen.'
  },
  'Relámpago Enlazante': {
    'nivel': '6',
    'i':
        'Rayo que salta entre objetivos causando 10d8 de daño de electricidad cada uno.'
  },
  'Círculo de la Muerte': {
    'nivel': '6',
    'i':
        'Área de 60 pies que inflige 8d6 de daño necrótico, salvación de Constitución reduce a la mitad.'
  },
  'Crear No Muertos': {
    'nivel': '6',
    'i':
        'Levanta esqueletos avanzados o ghouls bajo tu control durante 24 horas.'
  },
  'Desintegrar': {
    'nivel': '6',
    'i':
        'Rayo verde que destruye materia, causando 10d6 + 40 de daño si falla salvación de Destreza.'
  },
  'Mirada atemorizante': {
    'nivel': '6',
    'i':
        'Afecta la mente de un objetivo causando sueño, miedo o enfermedad temporalmente.'
  },
  'Carne a piedra': {
    'nivel': '6',
    'i': 'Convierte a un objetivo en piedra si falla salvación de Constitución.'
  },
  'Globo de invulnerabilidad': {
    'nivel': '6',
    'i':
        'Crea un área de 10 pies donde hechizos de 5º nivel o inferiores no afectan.'
  },
  'Curar': {
    'nivel': '6',
    'i':
        'Restaura 70 puntos de golpe a un objetivo y elimina estados de enfermedad y veneno.'
  },
  'Banquete de héroes': {
    'nivel': '6',
    'i':
        'Banquete mágico que otorga puntos de golpe máximos, ventaja en tiradas de salvación y inmunidad a miedo y veneno.'
  },
  'Esfera congelante de Otiluke': {
    'nivel': '6',
    'i':
        'Esfera de frío que explota causando 10d6 de daño y crea hielo en un área grande.'
  },
  'Baile irresistible de Otto': {
    'nivel': '6',
    'i': 'Obliga a un objetivo a bailar incapacitándolo durante la duración.'
  },
  'Aliado planar': {
    'nivel': '6',
    'i': 'Invoca una criatura extraplanar amistosa que obedece tus órdenes.'
  },
  'Rayo de sol': {
    'nivel': '6',
    'i':
        'Rayo de luz que inflige 6d8 de daño radiante y ciega a los enemigos en línea recta.'
  },
  'Muro de hielo': {
    'nivel': '6',
    'i':
        'Crea un muro de hielo de hasta 10 pies de grosor que bloquea movimiento y proyectiles.'
  },
  'Muro de espinas': {
    'nivel': '6',
    'i':
        'Crea un muro de espinas que inflige 7d8 de daño cortante a los que lo atraviesen.'
  },
  'Camino del viento': {
    'nivel': '6',
    'i':
        'Transforma hasta 10 aliados en forma gaseosa, permitiendo movimiento rápido a larga distancia.'
  },
};

// ==========================
// ATRIBUTOS POR CLASE Y NIVEL
// ==========================
final Map<String, Map<int, List<String>>> levelUpAttributes = {
  'Bárbaro': {
    1: ['FUE', 'CON'],
    2: ['CON'],
    3: ['FUE'],
    4: ['CON'],
    5: ['FUE'],
    6: ['CON'],
  },
  'Bardo': {
    1: ['CAR', 'DES'],
    2: ['DES'],
    3: ['CAR'],
    4: ['DES'],
    5: ['CAR'],
    6: ['DES'],
  },
  'Clérigo': {
    1: ['SAB', 'CAR'],
    2: ['CON'],
    3: ['SAB'],
    4: ['CAR'],
    5: ['SAB'],
    6: ['CON'],
  },
  'Druida': {
    1: ['SAB', 'INT'],
    2: ['INT'],
    3: ['SAB'],
    4: ['INT'],
    5: ['SAB'],
    6: ['INT'],
  },
  'Guerrero': {
    1: ['FUE', 'CON'],
    2: ['FUE'],
    3: ['CON'],
    4: ['FUE'],
    5: ['CON'],
    6: ['FUE'],
  },
  'Mago': {
    1: ['INT', 'SAB'],
    2: ['CON'],
    3: ['INT'],
    4: ['SAB'],
    5: ['INT'],
    6: ['CON'],
  },
  'Monje': {
    1: ['DES', 'SAB'],
    2: ['SAB'],
    3: ['DES'],
    4: ['SAB'],
    5: ['DES'],
    6: ['SAB'],
  },
  'Paladín': {
    1: ['FUE', 'CAR'],
    2: ['FUE'],
    3: ['CAR'],
    4: ['FUE'],
    5: ['CAR'],
    6: ['FUE'],
  },
  'Pícaro': {
    1: ['DES'],
    2: ['DES'],
    3: ['DES'],
    4: ['DES'],
    5: ['DES'],
    6: ['DES'],
  },
  'Hechicero': {
    1: ['CAR'],
    2: ['CAR'],
    3: ['CAR'],
    4: ['CAR'],
    5: ['CAR'],
    6: ['CAR'],
  },
  'Explorador': {
    1: ['DES', 'SAB'],
    2: ['SAB'],
    3: ['DES'],
    4: ['SAB'],
    5: ['DES'],
    6: ['SAB'],
  },
  'Brujo': {
    1: ['CAR'],
    2: ['CAR'],
    3: ['CAR'],
    4: ['CAR'],
    5: ['CAR'],
    6: ['CAR'],
  },
};

// ==========================
// HABILIDADES POR CLASE Y NIVEL
// ==========================
final Map<String, Map<int, List<String>>> levelUpSkills = {
  'Bárbaro': {
    1: ['Atletismo'],
    2: ['Supervivencia'],
    3: ['Perspicacia'],
    4: ['Intimidación'],
    5: ['Medicina'],
    6: ['Acrobacias'],
  },
  'Bardo': {
    1: ['Interpretación', 'Persuasión'],
    2: ['Engaño'],
    3: ['Juego de manos'],
    4: ['Historia'],
    5: ['Investigación'],
    6: ['Perspicacia'],
  },
  'Clérigo': {
    1: ['Medicina', 'Perspicacia'],
    2: ['Religión'],
    3: ['Persuasión'],
    4: ['Engaño'],
    5: ['Trato con animales'],
    6: ['Interpretación'],
  },
  'Druida': {
    1: ['Naturaleza', 'Perspicacia'],
    2: ['Supervivencia'],
    3: ['Medicina'],
    4: ['Atletismo'],
    5: ['Percepción'],
    6: ['Conocimiento arcano'],
  },
  'Guerrero': {
    1: ['Atletismo'],
    2: ['Intimidación'],
    3: ['Percepción'],
    4: ['Supervivencia'],
    5: ['Medicina'],
    6: ['Juego de manos'],
  },
  'Mago': {
    1: ['Investigación', 'Conocimiento arcano'],
    2: ['Historia'],
    3: ['Arcana avanzada'],
    4: ['Naturaleza'],
    5: ['Religión'],
    6: ['Investigación avanzada'],
  },
  'Monje': {
    1: ['Acrobacias', 'Perspicacia'],
    2: ['Atletismo'],
    3: ['Juego de manos'],
    4: ['Percepción'],
    5: ['Sigilo'],
    6: ['Medicina'],
  },
  'Paladín': {
    1: ['Persuasión', 'Intimidación'],
    2: ['Medicina'],
    3: ['Atletismo'],
    4: ['Supervivencia'],
    5: ['Engaño'],
    6: ['Perspicacia'],
  },
  'Pícaro': {
    1: ['Sigilo', 'Juego de manos'],
    2: ['Acrobacias'],
    3: ['Persuasión'],
    4: ['Engaño'],
    5: ['Investigación'],
    6: ['Percepción'],
  },
  'Hechicero': {
    1: ['Engaño', 'Persuasión'],
    2: ['Intimidación'],
    3: ['Interpretación'],
    4: ['Historia'],
    5: ['Investigación'],
    6: ['Conocimiento arcano'],
  },
  'Explorador': {
    1: ['Supervivencia', 'Percepción'],
    2: ['Sigilo'],
    3: ['Atletismo'],
    4: ['Trato con animales'],
    5: ['Investigación'],
    6: ['Naturaleza'],
  },
  'Brujo': {
    1: ['Engaño', 'Intimidación'],
    2: ['Persuasión'],
    3: ['Historia'],
    4: ['Conocimiento arcano'],
    5: ['Investigación'],
    6: ['Interpretación'],
  },
};

// ==========================
// HECHIZOS / TRUCOS POR CLASE Y NIVEL
// ==========================
final Map<String, Map<int, List<String>>> spellsByClassLevel = {
  'Mago': {
    1: ['Misil mágico', 'Escudo', 'Luces de baile', 'Mano de Mago'],
    2: ['Rayo de Escarcha', 'Invisibilidad', 'Imagen espejo'],
    3: ['Bola de fuego', 'Contraconjuro', 'Vuelo'],
    4: ['Polimorfo', 'Muro de fuego'],
    5: ['Desintegrar', 'Telequinesis'],
    6: ['Portal Arcano', 'Círculo de la Muerte'],
  },
  'Clérigo': {
    1: ['Curar heridas', 'Bendición', 'Comando'],
    2: ['Restauración menor', 'Ayuda', 'Silencio'],
    3: ['Palabra de curación masiva', 'Manto del cruzado', 'Animar muertos'],
    4: ['Guardián de la fe', 'Destierro'],
    5: ['Disipar el mal y el bien', 'Nube mortal'],
    6: ['Curar', 'Banquete de héroes'],
  },
  'Bardo': {
    1: ['Amigos', 'Guía', 'Luz'],
    2: ['Encantar persona', 'Cura heridas'],
    3: ['Disfrazarse', 'Invisibilidad'],
    4: ['Hipnotizar', 'Lealtad mágica'],
    5: ['Coro encantado', 'Rayo de desesperación'],
    6: ['Conjuro mayor', 'Inspiración heroica'],
  },
  'Druida': {
    1: ['Enredar', 'Fuego de hada'],
    2: ['Piel de corteza', 'Ayuda'],
    3: ['Hoja de llama', 'Esfera flamígera'],
    4: ['Polimorfo', 'Muro de fuego'],
    5: ['Contagio', 'Onda destructiva'],
    6: ['Portal Arcano', 'Círculo de la Muerte'],
  },
  'Hechicero': {
    1: ['Misil mágico', 'Escudo'],
    2: ['Rayo de Escarcha', 'Invisibilidad'],
    3: ['Bola de fuego', 'Contraconjuro'],
    4: ['Polimorfo', 'Muro de fuego'],
    5: ['Desintegrar', 'Telequinesis'],
    6: ['Portal Arcano', 'Círculo de la Muerte'],
  },
  'Brujo': {
    1: ['Invocar Familiar', 'Encantar persona'],
    2: ['Oscuridad', 'Rayo abrasador'],
    3: ['Maldición', 'Contraconjuro'],
    4: ['Polimorfo', 'Dominación'],
    5: ['Desintegrar', 'Telequinesis'],
    6: ['Banquete de héroes', 'Portal Arcano'],
  },
  'Paladín': {
    1: ['Bendición', 'Curar heridas'],
    2: ['Escudo de la fe', 'Ayuda'],
    3: ['Smite abrasador', 'Palabra de curación masiva'],
    4: ['Guardián de la fe', 'Destierro'],
    5: ['Disipar el mal y el bien', 'Nube mortal'],
    6: ['Curar', 'Banquete de héroes'],
  },
  'Guerrero': {
    1: ['Ataque poderoso', 'Defensa firme'],
    2: ['Golpe furioso', 'Inspirar aliados'],
    3: ['Contraataque', 'Segunda oportunidad'],
    4: ['Embate', 'Maestría táctica'],
    5: ['Ataque múltiple', 'Vigor heroico'],
    6: ['Furia incontrolable', 'Protección avanzada'],
  },
  'Bárbaro': {
    1: ['Furia', 'Resistencia'],
    2: ['Golpe brutal', 'Carga'],
    3: ['Rugido intimidante', 'Embate'],
    4: ['Defensa instintiva', 'Furia mayor'],
    5: ['Ataque salvaje', 'Resistencia mejorada'],
    6: ['Golpe demoledor', 'Indomable'],
  },
  'Pícaro': {
    1: ['Ataque furtivo', 'Esquiva'],
    2: ['Maniobra evasiva', 'Sigilo'],
    3: ['Desarme', 'Golpe preciso'],
    4: ['Infiltración', 'Robo experto'],
    5: ['Emboscada', 'Evasión'],
    6: ['Matar desde las sombras', 'Maestro del disfraz'],
  },
  'Monje': {
    1: ['Puño desarmado', 'Movimiento rápido'],
    2: ['Patada poderosa', 'Agilidad aumentada'],
    3: ['Golpe elemental', 'Concentración'],
    4: ['Defensa impecable', 'Velocidad sobrenatural'],
    5: ['Arte marcial maestro', 'Ataque relámpago'],
    6: ['Golpe perfecto', 'Trance meditativo'],
  },
  'Explorador': {
    1: ['Disparo preciso', 'Supervivencia'],
    2: ['Trampa', 'Exploración'],
    3: ['Ataque a distancia', 'Camuflaje'],
    4: ['Emboscada', 'Percepción aguda'],
    5: ['Tiro letal', 'Rastreo experto'],
    6: ['Maestría con armas', 'Movimiento sigiloso'],
  },
};
