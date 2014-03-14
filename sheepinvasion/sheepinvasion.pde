Map map;
// Position of player center in level coordinates
float playerX, playerY;
// Velocity of player
float vx, vy;
// Speed at which the player moves
float speed = 150;
// The player is a circle and this is its radius
float playerR = 10;
// Position of the goal center
// Will be set by restart
float goalX=0, goalY=0;
// Whether to illustrate special functions
boolean showSpecialFunctions=false;

// left / top border of the screen in map coordinates
float screenLeftX, screenTopY;

//integer für schleifen
int i, j;

//timer für schüss
float shotTimer, proShotTimer;

//objects
//shots
ArrayList<Shot> shots = new ArrayList<Shot>();
Shot myShot;
//enemies
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
Enemy myEnemy;

//minim Import
import ddf.minim.*;
Minim minim;
AudioPlayer player;

//Money
float money = 300;
//Vektoren
PShape towerBasic,towerMoney, towerPro, enemyBasic;

//Schwierigkeit
int difficulty = 25;

float time;
int GAMEWAIT=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3, TowerBuy=4, MoneyTowerBuy=5, ProTowerBuy=6;
int gameState;

PImage backgroundImg;

void setup() {
  //Lade Spielmusik
  minim = new Minim (this);
  //Lade Spielmusik (später loopen und beenden lassen
  player = minim.loadFile ("music/soundtrack.wav");
  player.play ();
  player.loop ();
  frame.setResizable(true);
  size( 900, 700 );
  restart();
  frameRate(24);

  shapeMode(CENTER);

  towerBasic = loadShape("images/towerBasic.svg");
  towerMoney = loadShape("images/towerMoney.svg");
  towerPro = loadShape("images/towerPro.svg");
  enemyBasic = loadShape("images/enemyBasic.svg");
}

void restart () {
  map = new Map( "levelthree.map");
  /*for ( int x = 0; x < map.w; ++x ) {
    for ( int y = 0; y < map.h; ++y ) {
      if ( map.at(x, y) == 'S' ) {
        playerX = map.centerXOfTile (x);
        playerY = map.centerYOfTile (y);
        map.set(x, y, 'F');
      }
      if ( map.at(x, y) == 'E' ) {
        goalX = map.centerXOfTile (x);
        goalY = map.centerYOfTile (y);
      }
    }
  }*/
  time=0;
  vx = 0;
  vy = 0;
  gameState = GAMEWAIT;
}

void keyPressed() {
  if ( keyCode == UP && vy == 0 ) {
    vy = -speed;
    vx = 0;
  }
  else if ( keyCode == DOWN && vy == 0 ) {
    vy = speed;
    vx = 0;
  }
  else if ( keyCode == LEFT && vx == 0 ) {
    vx = -speed;
    vy = 0;
  }
  else if ( keyCode == RIGHT && vx == 0 ) {
    vx = speed;
    vy = 0;
  }
  else if ( keyCode == 'S' ) showSpecialFunctions = !showSpecialFunctions;
}


void updatePlayer() {
  // update player
  float nextX = playerX + vx/frameRate,
  nextY = playerY + vy/frameRate;
  if ( map.testTileInRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "W_" ) ) {
    vx = -vx;
    vy = -vy;
    nextX = playerX;
    nextY = playerY;
  }
  else if ( map.testTileFullyInsideRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "H" ) ) {
    gameState=GAMEOVER;
  }

   else if ( map.testTileFullyInsideRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "P" ) ) {
     gameState=GAMEOVER;
  }

  else if ( map.testTileFullyInsideRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "E" ) ) {
    gameState=GAMEWON;
  }

  playerX = nextX;
  playerY = nextY;
}

// Maps input to an output, such that
//     - input0 is mapped to output0
//     - a increasing input by 1 increases output by factor
float map (float input, float input0, float output0, float factor) {
  return factor*(input-input0)+output0;
}

void drawBackground() {
  // Explanation to the computation of x and y:
  // If screenLeftX increases by 1, i.e. the main level moves 1 to the left on screen,
  // we want the background map to move 0.5 to the left, i.e. x decrease by 0.5
  // Further, imagine the center of the screen (width/2) corresponds to the center of the level
  // (map.widthPixel), i.e. screenLeftX=map.widthPixel()/2-width/2. Then we want
  // the center of the background image (backgroundImg.width/2) also correspond to the screen
  // center (width/2), i.e. x=-backgroundImg.width/2+width/2.
  float x = map (screenLeftX, map.widthPixel()/2-width/2, -backgroundImg.width/2+width/2, -0.5);
  float y = map (screenTopY, map.heightPixel()/2-height/2, -backgroundImg.height/2+height/2, -0.5);
  image (backgroundImg, x, y);
}


void drawMap() {
  // The left border of the screen is at screenLeftX in map coordinates
  // so we draw the left border of the map at -screenLeftX in screen coordinates
  // Same for screenTopY.
  map.draw( -screenLeftX, -screenTopY );
}


void drawPlayer() {
  // draw player
  noStroke();
  fill(0, 255, 255);
  ellipseMode(CENTER);
  ellipse( playerX - screenLeftX, playerY - screenTopY, 2*playerR, 2*playerR );

  // understanding this is optional, skip at first sight
  if (showSpecialFunctions) {
    // draw a line to the next hole
    Map.TileReference nextHole = map.findClosestTileInRect (playerX, playerY, 200, 200, "H");
    stroke(255, 0, 255);
    if (nextHole!=null) line (playerX-screenLeftX, playerY-screenTopY,
    nextHole.centerX-screenLeftX, nextHole.centerY-screenTopY);

    // draw line of sight to goal (until next wall) (understanding this is optional)
    stroke(0, 255, 255);
    Map.TileReference nextWall = map.findTileOnLine (playerX, playerY, goalX, goalY, "W");
    if (nextWall!=null)
      line (playerX-screenLeftX, playerY-screenTopY, nextWall.xPixel-screenLeftX, nextWall.yPixel-screenTopY);
    else
      line (playerX-screenLeftX, playerY-screenTopY, goalX-screenLeftX, goalY-screenTopY);
  }
}
// Malt die Buttons für die Tower und ändert auf Klick den GameState
void drawButton_Tower () {
  if (mouseX > 25 && mouseX < 25+200 && mouseY > 630 && mouseY < 630+50){
    fill(#9b59b6);
    rect(25, 630, 200, 50);

    if (mousePressed==true){
      gameState = TowerBuy;
      fill(#ffffff);
      rect(25, 630, 200, 50);
    }
  }
  else{
    fill(#f1c40f);
    rect(25, 630, 200, 50);
  }
  fill(#ffffff);
  textSize(18);
  textAlign(CENTER);
  text("Schussturm (15)", 200/2+25,630+33);
}

void drawButton_moneyTower () {
  if (mouseX > 280 && mouseX < 280+200 && mouseY > 630 && mouseY < 630+50){
    fill(#9b59b6);
    rect(280, 630, 200, 50);

    if (mousePressed==true){
      gameState = MoneyTowerBuy;
      fill(#ffffff);
      rect(280, 630, 200, 50);
    }
  }
  else{
    fill(#f1c40f);
    rect(280, 630, 200, 50);
  }
  fill(#ffffff);
  textSize(18);
  textAlign(CENTER);
  text("Geldturm (25)", 200/2+280,630+33);
}

void drawButton_proTower () {
  if (mouseX > 525 && mouseX < 525+200 && mouseY > 630 && mouseY < 630+60){
    fill(#9b59b6);
    rect(525, 700, 200, 60);

    if (mousePressed==true){
      gameState = ProTowerBuy;
      fill(#ffffff);
      rect(525, 630, 200, 60);
    }
  }
  else{
    fill(#f1c40f);
    rect(525, 630, 250, 50);
  }
  fill(#ffffff);
  textSize(18);
  textAlign(CENTER);
  text("Schussturm Upgrade (50)", 200/2+545,630+33);
}

// Pausiert das Spiel und lässt einen Tower auf das Feld bauen.
void mousePressed() {
      if (gameState==TowerBuy && map.atPixel(mouseX, mouseY) == 'G') {
       map.setPixel(mouseX, mouseY, 'T');
       money=money-15;
       gameState=GAMERUNNING;
      }

      //Pro Tower als Upgrade
      if (gameState==ProTowerBuy && map.atPixel(mouseX, mouseY) == 'T') {
       map.setPixel(mouseX, mouseY, 'P');
       money=money-50;
       gameState=GAMERUNNING;
      }
      if (gameState==MoneyTowerBuy && map.atPixel(mouseX, mouseY) == 'G') {
       map.setPixel(mouseX, mouseY, 'M');
       money=money-25;
       gameState=GAMERUNNING;
      }

}
// Überprüft wie viel Geld da ist und malt dann einen Button für mögliche Investitionen
void checkMoney(){
  textSize(24);
  textAlign(LEFT);
  fill(#ecf0f1);
  text("Du hast "+int(money)+" Münzen", 25,50);
  if (money>=15){
    drawButton_Tower();
  }
  if (money>=25){
    drawButton_moneyTower();
  }
  if (money>=50){
    drawButton_proTower();
  }
}

void drawText() {
  textAlign(CENTER, CENTER);
  fill(0, 255, 0);
  textSize(40);
  if (gameState==GAMEWAIT) text ("press space to start", width/2, height/2);
  else if (gameState==GAMEOVER) text ("game over", width/2, height/2);
  else if (gameState==GAMEWON) text ("won in "+ round(time) + " seconds", width/2, height/2);
}

// Malt die Tower für ein besseres Verständnis während des Kaufvorgangs
void towerDraw(float towerX1,float towerY1){
  shape(towerBasic,towerX1,towerY1,50,75);
}

void moneytowerDraw(float moneytowerX1,float moneytowerY1){
  shape(towerMoney,moneytowerX1,moneytowerY1,50,50);
}

void protowerDraw(float protowerX1,float protowerY1){
  shape(towerPro,protowerX1,protowerY1,50,75);
}
// Der Schuss  wird hier berechnet und gemalt. 
class Shot {
  float x;
  float y;
  int r;
  color c;

  Shot (float _x, float _y, int _r, color _c) {
    x=_x;
    y=_y;
    r=_r;
    c=_c;
  }

  void move() {
    x+=300/frameRate;
  }

boolean fail() {
	if (x>=width-200) {
		return true;
	}
	else {
		return false;
	}
}

  void run() {
    fill (c);
    ellipse(x,y,r,r);
  }
};
// Der  Gegner wird hier berechnet und gespawnt
class Enemy {
  float x;
  float y;
  int typ;

  Enemy (float _x, float _y, int _typ) {
    x=_x;
    y=_y;
    typ=_typ;
  }

  void move() {
    x-=30/frameRate;
  }

  void run() {
    shape(enemyBasic,x,y,75,50);
  }
};

void draw() {
  //screenLeftX = playerX - width/2;
  //screenTopY  = (map.heightPixel() - height)/2;

  //drawBackground();
  background(128);
  drawMap();
  playerX = mouseX;
  playerY = mouseY;
  checkMoney();
  drawPlayer();
  drawText();

   if (gameState==TowerBuy) {
    towerDraw(mouseX,mouseY);
  }

   if (gameState==MoneyTowerBuy) {
    moneytowerDraw(mouseX,mouseY);
  }

  if (gameState==ProTowerBuy) {
    protowerDraw(mouseX,mouseY);
  }

    if (gameState==GAMERUNNING) {
    //updatePlayer();
    time+=1/frameRate;
    shotTimer+=1/frameRate;
    proShotTimer+=1/frameRate;
    //money=money+1; //auskommentiert, da Geld momentan nur durch moneyTower generiert wird. Viel spannender, oder?

  //schleife die prüft wo türme sind, vorerst ellipsen als platzhalter
  if (shotTimer >=1) {
    for (i = 0; i < map.w; i++) {
      for (j = 0; j < map.h; j++) {
        if (map.at(i,j) == 'T'){ //&&check ob wert noch nicht in array ist
          shots.add(
            new Shot((i+1)*100-28,(j+1)*100-65, 3, #2aff00)
          );
        }
      }
    }
    shotTimer = 0;
  }

  //schleife die prüft wo türme sind, vorerst ellipsen als platzhalter
  if (proShotTimer >=0.4) {
    for (i = 0; i < map.w; i++) {
      for (j = 0; j < map.h; j++) {
        if (map.at(i,j) == 'P'){
          shots.add(
            new Shot((i+1)*100-24,(j+1)*100-65, 4, #00e0ff)
          );
        }
      }
    }
    proShotTimer = 0;
  }

  //schleife die gegner spawnt
  //umso niedriger die Schwierigkeit, desto häufiger spawnen Gegner
  for (i = 0; i < map.w; i++) {
    for (j = 0; j < map.h; j++) {
      if (map.at(i,j) == 'S' && int(random(0,difficulty*frameRate))==0){
        enemies.add(
          new Enemy((i+1)*100+50,(j+1)*100-50, 1)
        );
      }
    }
  }

  //MoneyTower machen Geld!
  for (i = 0; i < map.w; i++) {
    for (j = 0; j < map.h; j++) {
      if (map.at(i,j) == 'M'){
        money+=10/frameRate;
      }
    }
  }

  }
  else if (keyPressed && key==' ') {
    if (gameState==GAMEWAIT) gameState=GAMERUNNING;
    else if (gameState==GAMEOVER || gameState==GAMEWON) restart();
  }
  for (int i = 0; i < shots.size(); ++i) {
    shots.get(i).move();
    shots.get(i).run();
    if (shots.get(i).fail()) {
    	shots.remove(i);
    	i--;
    }
  }
  for (int i = 0; i < enemies.size(); ++i) {
    enemies.get(i).move();
    enemies.get(i).run();
  }

}
