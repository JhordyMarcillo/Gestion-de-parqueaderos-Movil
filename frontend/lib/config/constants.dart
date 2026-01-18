class ApiConstants {
  // Android Emulator: 'http://10.0.2.2:8080/api'
  // Celular Físico: 'http://ip:8080/api'
  static const String baseUrl = 'http://192.xx.xx.xx:8080/';

  static const String loginEndpoint = 'api/auth/login';
  static const String registerEndpoint = 'api/auth/register';
  // Si tu controlador en Java es EspacioController con @RequestMapping("/api/espacios")
  static const String parkingEndpoint = 'api/espacios';
}