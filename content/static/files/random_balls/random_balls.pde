// === settings ===
int nb_balls = 90;
int ball_size_min = 25;
int ball_size_max = 225;
float line_factor = 1.1;

int[][] balls = new int[nb_balls][3];


void setup(){
  size(900,450);
  noLoop();
  noStroke();
}

// create the balls array
void init_balls(){
  for (int i = 0; i < nb_balls; i++){
    balls[i][0] = int(random(0, width));  // x pos
    balls[i][1] = int(random(0, height)); // y pos
    balls[i][2] = int(random(25,125+1));  // size of outer ball
  }  
}

void draw_ball(int x, int y, int ball_size){
  fill(255);
  ellipse(x, y, 5, 5);
  fill(13, 15, 56, 70);
  ellipse(x, y, ball_size, ball_size);  
}

void draw_lines(){
  int x; // x pos for iteration
  int y; // y pos ...
  int s; // size ...
  float distance; // distance ...
  for (int i=0; i < nb_balls; i++){
    x = balls[i][0];
    y = balls[i][1];
    s = balls[i][2];
    for (int j=0; j <nb_balls; j++){
      distance = sqrt(pow(x -balls[j][0],2) + pow(y - balls[j][1],2));
      if(!((x == balls[j][0]) && (y == balls[j][1])) && (distance <= s*line_factor)){
        stroke(255);
        line(x,y,balls[j][0], balls[j][1]);
        noStroke();
      }
    }
  }
}

void draw_full_frame(){
  background(70);
  draw_lines();
  int x; // x pos for iteration
  int y; // y pos ...
  int s; // size ...
  for (int i=0; i < nb_balls; i++){
    x = balls[i][0];
    y = balls[i][1];
    s = balls[i][2];
    draw_ball(x, y, s);
  }
}

void draw(){
  init_balls();
  draw_full_frame();
}

void keyPressed(){
  if (key == 'r' || key == 'R'){
    redraw();
  } else if (key == 's' || key == 'S'){
    saveFrame("frame-####.png");
  }
}
