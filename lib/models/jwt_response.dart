class JwtResponse {
  String jwtToken;

  JwtResponse({
    this.jwtToken,
  });

  @override
  String toString() {
    return "{jwtToken: ${this.jwtToken}}";
  }

  JwtResponse.fromJson(Map<String, dynamic> json) : jwtToken = json['jwtToken'];

  Map<String, dynamic> toJson() => {
        'jwtToken': jwtToken,
      };
}
