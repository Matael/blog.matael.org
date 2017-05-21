void setup(){
  size(120,120);
  background(200);
}


void draw(){
  fill(255);
  ellipse(width/2, height/2, 5, 5);
  fill(13, 15, 56, 70);
  ellipse(width/2, height/2, width-10, height-10);
}

void mousePressed(){
  // export png quand on clique
  save("ball_alone.png");
}
