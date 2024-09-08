class PlayerModel {
  final String id;
  final String nickname;
  final int state; // 0 - Main menu; 1 - Invite pending; 2 - WaitRoom; 3 - In game

  PlayerModel({required this.id, required this.nickname, required this.state});

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['ID'] as String,
      nickname: map['Nickname'] as String,
      state: (map['State'] as int),
    );
  }
}