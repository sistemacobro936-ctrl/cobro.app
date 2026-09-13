class AuthEntity {
    final String accessToken;
    final UsuarioEntity usuario;

    AuthEntity({
        required this.accessToken,
        required this.usuario,
    });

}

class UsuarioEntity {
    final String id;
    final String nombre;
    final String apellido;
    final String email;

    UsuarioEntity({
        required this.id,
        required this.nombre,
        required this.apellido,
        required this.email,
    });

}
