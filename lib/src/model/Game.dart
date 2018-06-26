part of BattleCity;

class Game {
  final int delay = 35;
  Level level;
  Timer t;
  int levelCount = 0;
  int currentLevel = 0;
  Set<Moveable> toRemove = new Set();
  int speedCount = 0;
  Function function;
  int score = 0;
  bool _running = false;

  Game(void this.function(String reason)) {
  }

  Future loadMeta() {
    return HttpRequest.getString("../json/meta.json").then((json) {
      Map m = JSON.decode(json);
      this.levelCount = m['lvlCount'];
    });
  }

  Future loadNextLevel() {
    return LevelLoader.load(currentLevel, this, (level) {
      this.level = level;
    });
  }

  void startLoop() {
    if(_running) return;
    _running = true;
    this.t = new Timer.periodic(new Duration(milliseconds: delay), (t) {
      this.levelLoop();
    });
  }

  void stopLoop() {
    _running = false;
    this.t.cancel();
  }

  /**
   * true if exists, false if all levels have been complete
   */

  /**
   * @return true on completion, false if lost
   */
  void levelLoop() {
    for (int i = 0; i < level.gamefield.moveables.length; i++) {
      level.gamefield.moveables[i].move(speedCount);
    }
    for (int i = 0; i < toRemove.length; i++) {
      for (int j = 0; j < toRemove.elementAt(i).positions.length; j++) {
        for (int k = 0; k < toRemove.elementAt(i).positions[j].length; k++) {
          level.gamefield
              .getField(toRemove.elementAt(i).positions[j][k])
              .moveable = null;
        }
      }
      level.gamefield.moveables.remove(toRemove.elementAt(i));
    }


    toRemove = new Set();
    _checkWinLose();
    speedCount++;
  }


  void _checkWinLose() {
    if (level.player.health < 1 || level.gamefield.goals.length < 1) {
      stopLoop();
      currentLevel = 0;
      function("lose");
    }
    if(level.gamefield.enemyCount < 1){
      stopLoop();
      currentLevel++;
      function("win");
    }
  }
}