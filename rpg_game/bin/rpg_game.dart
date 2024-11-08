import 'dart:io';
import 'dart:math';

class Character {
  String name;
  int health;
  int attack;
  int defense;

  Character(this.name, this.health, this.attack, this.defense);

  void attackMonster(Monster monster) {
    int damage = max(0, attack - monster.defense);
    monster.health -= damage;
    print('$name가 ${monster.name}에게 $damage의 피해를 입혔습니다.');
  }

  void defend() {
    health += defense;
    print('$name가 방어를 성공해 $defense만큼 체력이 상승했습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}

class Monster {
  String name;
  int health;
  int attack;
  int defense = 0;

  Monster(this.name, this.health, int characterDefense)
      : attack = max(Random().nextInt(30) + 1, characterDefense);

  void attackCharacter(Character character) {
    int damage = max(0, attack - character.defense);
    character.health -= damage;
    print('$name가 ${character.name}에게 $damage의 피해를 입혔습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack');
  }
}

class Game {
  late Character character;
  List<Monster> monsters = [];
  int defeatedMonsters = 0;

  void loadCharacterStats() {
    try {
      final file = File('characters.txt');
      if (!file.existsSync()) {
        print('characters.txt 파일이 존재하지 않습니다. 기본 캐릭터를 생성합니다.');
        character = Character('기본캐릭터', 50, 10, 5);
        return;
      }
      final contents = file.readAsStringSync();
      final stats = contents.split(',');
      if (stats.length != 3) throw FormatException('Invalid character data');

      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);

      print('캐릭터의 이름을 입력하세요:');
      String? name = stdin.readLineSync();
      if (name == null || name.isEmpty || !RegExp(r'^.+\$').hasMatch(name)) {
        print('잘못된 이름입니다. 기본 이름으로 설정합니다.');
        name = '기본캐릭터';
      }

      character = Character(name, health, attack, defense);
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e. 기본 캐릭터를 생성합니다.');
      character = Character('기본캐릭터', 50, 10, 5);
    }
  }

  void loadMonsterStats() {
    try {
      final file = File('monsters.txt');
      if (!file.existsSync()) {
        print('monsters.txt 파일이 존재하지 않습니다. 기본 몬스터를 생성합니다.');
        monsters.add(Monster('기본몬스터', 30, character.defense));
        return;
      }
      final lines = file.readAsLinesSync();
      for (var line in lines) {
        final stats = line.split(',');
        if (stats.length != 2) throw FormatException('Invalid monster data');

        String name = stats[0];
        int health = int.parse(stats[1]);

        monsters.add(Monster(name, health, character.defense));
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e. 기본 몬스터를 생성합니다.');
      monsters.add(Monster('기본몬스터', 30, character.defense));
    }
  }

  Monster getRandomMonster() {
    return monsters[Random().nextInt(monsters.length)];
  }

  void battle() {
    while (monsters.isNotEmpty && character.health > 0) {
      Monster monster = getRandomMonster();
      print('새로운 몬스터가 나타났습니다!');
      character.showStatus();
      monster.showStatus();

      while (monster.health > 0 && character.health > 0) {
        print('${character.name}의 턴 (공격: 1, 방어: 2)');
        String? choice = stdin.readLineSync();

        if (choice == null || (choice != '1' && choice != '2')) {
          print('잘못된 입력입니다. 1 또는 2를 입력해주세요.');
          continue;
        }

        switch (choice) {
          case '1':
            character.attackMonster(monster);
            break;
          case '2':
            character.defend();
            break;
        }

        character.showStatus();
        monster.showStatus();

        if (monster.health > 0) {
          print('${monster.name}의 턴입니다.');
          monster.attackCharacter(character);
          character.showStatus();
          monster.showStatus();
        }
      }

      if (character.health > 0) {
        print('${monster.name}을(를) 물리쳤습니다!');
        monsters.remove(monster);
        defeatedMonsters++;
        if (monsters.isNotEmpty) {
          print('다음 몬스터와 대결하시겠습니까? (y/n)');
          String? continueGame = stdin.readLineSync();
          if (continueGame == null || continueGame.toLowerCase() != 'y') {
            break;
          }
        }
      }
    }

    if (character.health > 0) {
      print('축하합니다! 모든 몬스터를 물리쳤습니다.');
    } else {
      print('게임 종료. 패배하셨습니다.');
    }

    saveResult();
  }

  void saveResult() {
    print('결과를 저장하시겠습니까? (y/n)');
    String? choice = stdin.readLineSync();
    if (choice != null && choice.toLowerCase() == 'y') {
      final file = File('result.txt');
      String result =
          '캐릭터 이름: ${character.name}\n남은 체력: ${character.health}\n게임 결과: ${character.health > 0 ? "승리" : "패배"}';
      file.writeAsStringSync(result);
      print('결과가 저장되었습니다.');
    }
  }

  void startGame() {
    loadCharacterStats();
    loadMonsterStats();
    battle();
  }
}

void main() {
  Game game = Game();
  game.startGame();
}
