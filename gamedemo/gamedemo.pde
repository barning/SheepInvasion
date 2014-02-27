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

float time;
int GAMEWAIT=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3;
int gameState;

PImage backgroundImg;

void setup() {
  size( 500, 500 );
  backgroundImg = loadImage ("images/fire.jpg");
  restart();
  frameRate(24);
}

void restart () {
  map = new Map( "demo.map");
  for ( int x = 0; x < map.w; ++x ) {
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
  }
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


void drawText() { 
  textAlign(CENTER, CENTER);
  fill(0, 255, 0);  
  textSize(40);  
  if (gameState==GAMEWAIT) text ("press space to start", width/2, height/2);
  else if (gameState==GAMEOVER) text ("game over", width/2, height/2);
  else if (gameState==GAMEWON) text ("won in "+ round(time) + " seconds", width/2, height/2);
}


void draw() {
  if (gameState==GAMERUNNING) {
    updatePlayer();
    time+=1/frameRate;
  }
  else if (keyPressed && key==' ') {
    if (gameState==GAMEWAIT) gameState=GAMERUNNING;
    else if (gameState==GAMEOVER || gameState==GAMEWON) restart();
  }
  screenLeftX = playerX - width/2;
  screenTopY  = (map.heightPixel() - height)/2;

  drawBackground();
  drawMap();
  drawPlayer();
  drawText();
}




