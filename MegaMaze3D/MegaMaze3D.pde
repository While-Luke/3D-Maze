int w = 15, l = 15, h = 15;
float camx = width/2, camy = height/2, camz = (height/2.0) / tan(PI*30.0 / 180.0);
float eyex = width/2.0, eyey = height/2.0, eyez = 0;
float horizontal = 0, vertical = PI/2;
boolean[] keys = new boolean[123];

boolean[][][][] maze = new boolean[l][h][w][6]; //FRONT, TOP, LEFT, RIGHT, BOTTOM, BACK

void setup() {
  size(1000, 1000, P3D);
  frameRate(60);
  textAlign(CENTER, CENTER);
  
  generateMaze();
}

void draw() {
  background(255);
  
  updateCamera();
  camera(camx, camy, camz, eyex, eyey, eyez, 0, 1, 0);
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(PI/3.0, width/height, cameraZ/100.0, cameraZ*10.0);
  //System.out.println(camx + " " + camy + " " + camz);
  
  for(int i = 0; i < l; i++){
    for(int j = 0; j < h; j++){
      for(int k = 0; k < w; k++){
        fill(map(j, 0, w, 250, 100));
        pushMatrix();
        translate(i*100, j*100, -k*100);
        if(maze[i][j][k][0]) square(0, 0, 100); //FRONT
        rotateX(PI/2);
        if(maze[i][j][k][1]) square(0, 0, 100); //TOP
        rotateY(PI/2);
        if(maze[i][j][k][2]) square(0, 0, 100); //LEFT
        translate(100, 100, 100);
        rotateZ(PI);
        if(maze[i][j][k][3]) square(0, 0, 100); //RIGHT
        rotateY(PI/2);
        //if(maze[i][j][k][4]) square(0, 0, 100); //BOTTOM
        rotateX(PI/2);
        if(maze[i][j][k][5]) square(0, 0, 100); //BACK
        popMatrix();
      }
    }
  }
  pushMatrix();
  translate((l-1)*100, (h*100)-0.1, -(w-1)*100);//goal
  rotateX(PI/2);
  fill(0, 0, 255);
  square(0, 0, 100);
  popMatrix();
  
  pushMatrix(); //floor
  translate(0, (h*100), -(w-1)*100);
  rotateX(PI/2);
  fill(100);
  square(0, 0, l*100);
  popMatrix();
  
  pushMatrix(); //green plane
  translate(-l*100, (h*100)+20, -(w)*300);
  rotateX(PI/2);
  fill(#6FF074);
  square(0, 0, l*400);
  popMatrix();
  
  
  hint(DISABLE_DEPTH_TEST);
  camera();
  int x = int(camx/100);
  int y = int(camy/100);
  int z = int(-(camz-100)/100);
  if(x == l-1 && y == h-1 && z == w-1){
    textSize(100);
    fill(255,0,0);
    text("Finish", width/2, height/2 - 100);
    text("Press R for next maze", width/2, height/2 + 100);
  }
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed(){
  if(key == 'r'){
    int x = int(camx/100);
    int y = int(camy/100);
    int z = int(-(camz-100)/100);
    if(x == l-1 && y == h-1 && z == w-1){
      generateMaze();
      camx = 50; camy = 50; camz = (50/2.0) / tan(PI*30.0 / 180.0);
      eyex = width/2.0; eyey = height/2.0; eyez = 0;
      return;
    }
  }
  if(key < 123) keys[key] = true;
  if(key == ' '){
    int x = int(camx/100);
    int y = int(camy/100);
    int z = int(-(camz-100)/100);
    if(!maze[x][y][z][1]) camy -= 100;
  }
  if(keyCode == SHIFT){
    int x = int(camx/100);
    int y = int(camy/100);
    int z = int(-(camz-100)/100);
    //System.out.println(camz);
    //System.out.println(x + " " + y + " " + z);
    if(!maze[x][y][z][4]) camy += 100;
  }
}

void keyReleased(){
  if(key < 123) keys[key] = false;
}

void mouseDragged(){
  float cx = -(mouseX - pmouseX)/100.0;
  float cy = (mouseY - pmouseY)/100.0;
  horizontal+=cx;
  vertical+=cy;
  if(vertical < 0.05) vertical = 0.05;
  if(vertical > PI-0.05) vertical = PI-0.05;
  int r = 10;
  eyex = camx + r*sin(vertical)*cos(horizontal);
  eyey = camy + r*cos(vertical);
  eyez = camz + r*sin(vertical)*sin(horizontal);
}

void updateCamera(){
  if(keys['w']){
    camz += 2*sin(horizontal);
    camx += 2*cos(horizontal);
  }
  if(keys['s']){
    camz -= 2*sin(horizontal);
    camx -= 2*cos(horizontal);
  }
  if(keys['a']){
    camx += 2*sin(horizontal);
    camz -= 2*cos(horizontal);
    
  }
  if(keys['d']){
    camx -= 2*sin(horizontal);
    camz += 2*cos(horizontal);
  }
  
  int x = int(camx/100);
  int y = int(camy/100);
  int z = int(-(camz-100)/100);//FRONT, TOP, LEFT, RIGHT, BOTTOM, BACK
  if(maze[x][y][z][2] && camx % 100 < 10) camx = x*100+10;
  if(maze[x][y][z][3] && camx % 100 > 90) camx = x*100+90;
  if(camz > 0){
    if(maze[x][y][z][0] && camz % 100 < 10) camz = -z*100+10;
    if(maze[x][y][z][5] && camz % 100 > 90) camz = -z*100+90;
  }
  else{
    if(maze[x][y][z][5] && abs(camz) % 100 < 10) camz = (-z*100)+90;
    if(maze[x][y][z][0] && abs(camz) % 100 > 90) camz = (-z*100)+10;
  }
  
  int r = 10;
  eyex = camx + r*sin(vertical)*cos(horizontal);
  eyey = camy + r*cos(vertical);
  eyez = camz + r*sin(vertical)*sin(horizontal);
}


void generateMaze(){
  //System.out.println("Start");
  for(int i = 0; i < l; i++){
    for(int j = 0; j < h; j++){
      for(int k = 0; k < w; k++){
        maze[i][j][k] = new boolean[]{true, true, true, true, true, true};
      }
    }
  }
  
  ArrayList<int[]> generators = new ArrayList();
  generators.add(new int[]{0,0,0});
  boolean[][][] seen = new boolean[l][h][w];
  seen[0][0][0] = true;
  
  while(!generators.isEmpty()){
    //System.out.println(generators.size());
    int size = generators.size();
    for(int i = 0; i < size; i++){
      if(updateGenerator(generators.get(i), seen, generators)) {
        i--;
        size--;
      }
    }
    if(generators.isEmpty()){
      for(int i = 0; i < l; i++){
        for(int j = 0; j < h; j++){
          for(int k = 0; k < w; k++){
            if(!seen[i][j][k]){
              generators.add(new int[]{i, j, k});
              if(i == 0){
                maze[i][j][k][3] = false;
                maze[i+1][j][k][2] = false;
              }
              else{
                maze[i][j][k][2] = false;
                maze[i-1][j][k][3] = false;
              }
              seen[i][j][k] = true;
              i = l;
              j = h;
              k = w;
            }
          }
        }
      }
    }
  }
  
  //System.out.println("End");
}

boolean updateGenerator(int[] generator, boolean[][][] seen, ArrayList<int[]> generators){
  int x = generator[0];
  int y = generator[1];
  int z = generator[2];
  ArrayList<int[]> movingOptions = new ArrayList();
  if(x - 1 > 0 && !seen[x-1][y][z]){
    movingOptions.add(new int[]{x-1, y, z});
  }
  if(x + 1 < l && !seen[x+1][y][z]){
    movingOptions.add(new int[]{x+1, y, z});
  }
  if(y - 1 > 0 && !seen[x][y-1][z]){
    movingOptions.add(new int[]{x, y-1, z});
  }
  if(y + 1 < h && !seen[x][y+1][z]){
    movingOptions.add(new int[]{x, y+1, z});
  }
  if(z - 1 > 0 && !seen[x][y][z-1]){
    movingOptions.add(new int[]{x, y, z-1});
  }
  if(z + 1 < w && !seen[x][y][z+1]){
    movingOptions.add(new int[]{x, y, z+1});
  }
  
  if(movingOptions.size() == 0){
    generators.remove(generator);
    return true;
  }
  
  int[] moving = movingOptions.get(int(random(movingOptions.size())));
  int mx = moving[0];
  int my = moving[1];
  int mz = moving[2];
  int cx = moving[0] - x;
  int cy = moving[1] - y;
  int cz = moving[2] - z;
  
  //FRONT, TOP, LEFT, RIGHT, BOTTOM, BACK
  //remove walls
  if(cx == -1){
    maze[x][y][z][2] = false;
    maze[mx][my][mz][3] = false;
  }
  if(cx == 1){
    maze[x][y][z][3] = false;
    maze[mx][my][mz][2] = false;
  }
  if(cy == -1){
    maze[x][y][z][1] = false;
    maze[mx][my][mz][4] = false;
  }
  if(cy == 1){
    maze[x][y][z][4] = false;
    maze[mx][my][mz][1] = false;
  }
  if(cz == -1){
    maze[x][y][z][5] = false;
    maze[mx][my][mz][0] = false;
  }
  if(cz == 1){
    maze[x][y][z][0] = false;
    maze[mx][my][mz][5] = false;
  }
  
  if(movingOptions.size() > 1 && int(random(3)) == 0){//add new generator
    movingOptions.remove(moving);
    int[] newGen = movingOptions.get(int(random(movingOptions.size())));
    generators.add(newGen);
    
    mx = newGen[0];
    my = newGen[1];
    mz = newGen[2];
    cx = newGen[0] - x;
    cy = newGen[1] - y;
    cz = newGen[2] - z;
    
    //remove walls
    if(cx == -1){
      maze[x][y][z][2] = false;
      maze[mx][my][mz][3] = false;
    }
    if(cx == 1){
      maze[x][y][z][3] = false;
      maze[mx][my][mz][2] = false;
    }
    if(cy == -1){
      maze[x][y][z][1] = false;
      maze[mx][my][mz][4] = false;
    }
    if(cy == 1){
      maze[x][y][z][4] = false;
      maze[mx][my][mz][1] = false;
    }
    if(cz == -1){
      maze[x][y][z][5] = false;
      maze[mx][my][mz][0] = false;
    }
    if(cz == 1){
      maze[x][y][z][0] = false;
      maze[mx][my][mz][5] = false;
    }
  
    seen[newGen[0]][newGen[1]][newGen[2]] = true;
  }
  
  generator[0] = mx;
  generator[1] = my;
  generator[2] = mz;
  
  seen[mx][my][mz] = true;
  
  return false;
}
