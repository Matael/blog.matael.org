void setup(){
  size(300,120);
  background(200);
}


void draw(){
  stroke(255);
  line(width/4,height/2,3*width/4,height/2);
  noStroke();
  fill(255);
  ellipse(width/4, height/2, 5, 5);
  fill(13, 15, 56, 70);
  ellipse(width/4, height/2, height-10, height-10);
  fill(255);
  ellipse(3*width/4, height/2, 5, 5);
  fill(13, 15, 56, 70);
  ellipse(3*width/4, height/2, height-50, height-50);
}

void mousePressed(){
  // export png quand on clique
  save("balls_linked.png");
}
