import java.util.Collections;
Table table;

ArrayList<Condition> conditions = new ArrayList<Condition>();

int width = 900;
int height = 400;

int timestamp = 0;
int conditionNumber = 0;
int maxConditionNumber = 8;
int trial = 0;
int maxTrial = 35;
int success = -1;
int keyType = 0;

int startTime = 0;
int loopTime = 0;
int zone_time = loopTime - startTime;
boolean terminate = false;
boolean stopMoving = false;

Condition nowCondition;
Target nowTarget;
Zone nowZone;

class Condition {
  int index;
  int t_cue;
  int t_zone;
  int period;
  
  Target target;
  Zone zone;
  
  Condition(int index, int t_cue, int t_zone, int period) {
    this.index = index;
    this.t_cue = t_cue;
    this.t_zone = t_zone;
    this.period = period;
  }
}

class Target {
  float velocity;
  float ellipse_position;
  float default_location;
  float pixelvelocity;
  
  Target (float velocity, float ellipse_position) {
    this.velocity = velocity;
    this.ellipse_position = ellipse_position;
    this.default_location = ellipse_position;
  }
  
  void createTarget() {
    fill(#FFFFFF);
    ellipse(ellipse_position, height/2, 50, 50);
  }
  
  void move(float time) {
    pixelvelocity = velocity*time;
    ellipse_position += pixelvelocity;
  }
  
  void renew() {
    ellipse_position = default_location;
  }
}

class Zone {
  int zone_position;
  int zone_left;
  int zone_width;
  
  Zone (int x, int y) {
    zone_left = x;
    zone_width = y;
  }
  
  void createZone() {
    fill(#320000);
    rectMode(CORNERS);
    rect(zone_left, 50, zone_width, height); //topleft, bottomright corner
  }
  
  void changeColor() {
    fill(#00FF00);
    rectMode(CORNERS);
    rect(zone_left, 50, zone_width, height);
  }
}

void settings() {
  size(width, height, P2D);
  pixelDensity(displayDensity());
}

void setup() {
  frameRate(60);
  initializeConditions();
  initializeTable();
  initializeDisplay();
}

void initializeConditions() {
  conditions.add(new Condition(1, 0, 80, 1000));
  conditions.add(new Condition(2, 0, 150, 1000));
  conditions.add(new Condition(3, 0, 80, 1500));
  conditions.add(new Condition(4, 0, 150, 1500));
  conditions.add(new Condition(5, 100, 80, 1000));
  conditions.add(new Condition(6, 100, 150, 1000));
  conditions.add(new Condition(7, 100, 80, 1500));
  conditions.add(new Condition(8, 100, 150, 1500));
  Collections.shuffle(conditions);
}

void initializeTable() {
  table = new Table();
  table.addColumn("timestamp");
  table.addColumn("cond");
  table.addColumn("trial");
  table.addColumn("success");
  table.addColumn("t_cue");
  table.addColumn("t_zone");
  table.addColumn("p");
  table.addColumn("key");
}

void initializeDisplay() {
  float velocity;
  int zoneLeft;
  int zoneWidth;
  int t_cue2;
  int t_zone2;
  
  for (int i=0; i<8; i++) {
    Condition now = conditions.get(i);
    t_cue2 = now.t_cue;
    t_zone2 = now.t_zone;
    if (t_cue2 == 0) {
      if (t_zone2 == 80) {
        zoneLeft = 0;
        zoneWidth = 48;
      }
      else {
        zoneLeft = 0;
        zoneWidth = 90;
      }
    }
    else {
      if (t_zone2 == 80) {
        zoneLeft = 60;
        zoneWidth = 48;
      }
      else {
        zoneLeft = 60;
        zoneWidth = 90;
      }
    }
    
    velocity = (float) zoneWidth/t_zone2;
    
    Zone zone = new Zone(zoneLeft, zoneWidth);
    now.zone = zone;
    
    Target target;
    if (t_cue2 == 0) {
      target = new Target(velocity, 0);
    }
    else {
      target = new Target(velocity, 60);
    }
    now.target = target;
  }
}

void draw() {
  checkTime();
  background(#000000);
  String label = "Remaining trials: " + (36 - trial) + "      Condition:  " + conditionNumber + "      " + (keyType == 0 ? "keyPressed" : "keyReleased");
  textSize(15);
  fill(#FFFFFF);
  text(label, 500, 30);
  
  if (terminate) exit();
  checkCondition();
  nowTarget.move(timestamp);
  display();
}

void checkCondition() {
  if (nowCondition == null) {
    nowCondition = conditions.get(conditionNumber);
    nowTarget = nowCondition.target;
    nowZone = nowCondition.zone;
    conditionNumber ++;
    return;
  }
}

void checkTime() {
  int nowTime = millis();
  if (startTime == 0) {
    startTime = nowTime;
    timestamp = 0;
    trial = 1;
    return;
  }
  else {
    timestamp = nowTime - startTime;
    if (timestamp >= 1000) {
      startTime = nowTime;
      timestamp = 0;
      checkTrial();
    }
  }
}

void display() {
  nowZone.createZone();
  if (!stopMoving) {
    nowTarget.createTarget();
  }
}

boolean assessResult(int loopTime) {
  int gap = loopTime - startTime;
  if (gap >= nowCondition.t_cue && gap <= (nowCondition.t_zone + nowCondition.t_cue)) {
    success = 1;
    return true;
  }
  else {
    success = 0;
    return false;
  }
}

void keyPressed() {
  loopTime  = millis();
  if (keyType == 0 && success == -1 && nowCondition != null && (loopTime - startTime <= nowCondition.period)) {
    stopMoving = true;
    if (assessResult (loopTime)) {
      nowZone.changeColor();
    }
    inputToTable();
  }
}

void keyReleased() {
  loopTime = millis();
  if (keyType == 1 && success == -1 && nowCondition != null && (loopTime - startTime <= nowCondition.period)) {
    stopMoving = true;
    if (assessResult(loopTime)) {
      nowZone.changeColor();
    }
    inputToTable();
  }
}

void inputToTable() {
  TableRow newRow = table.addRow();
  newRow.setInt("timestamp", (loopTime - startTime - nowCondition.t_cue));
  newRow.setInt("cond", nowCondition.index);
  newRow.setInt("trial", trial);
  newRow.setInt("success", success);
  newRow.setInt("t_cue", nowCondition.t_cue);
  newRow.setInt("t_zone", nowCondition.t_zone);
  newRow.setInt("p", nowCondition.period);
  newRow.setInt("key", keyType);
}

void renewValues() {
  loopTime = 0;
  success = -1;
  stopMoving = false;
}

void switchCondition() {
  nowCondition = null;
  trial = 1;;
  renewValues();
  delay(1000);
}

void switchKeyType() {
  nowCondition = null;
  conditionNumber = 0;
  trial = 1;;
  renewValues();
  keyType = 1;
}

void checkTrial() {
  if (success > -1) {
    if (trial == maxTrial) {
      if (keyType == 0) {
        if (conditionNumber < maxConditionNumber) {
          switchCondition();
        }
        else {
          switchKeyType();
          delay(3000);
        }
      }
      else {
        if (conditionNumber < maxConditionNumber) {
          switchCondition();
        }
        else {
          background(0);
          saveTable(table, "2019199061.csv");
          terminate = true;
        }
      }
    }
    else {
      renewValues();
      trial++;
    }
  }
  nowTarget.renew();
}
