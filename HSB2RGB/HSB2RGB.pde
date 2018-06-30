float HSB_colorWidth = 300;

float SB_start_x = 30;
float SB_start_y = 240;
float HSB_width = 800;
float SB_height = 400;

float textarea_start_x = SB_start_x+HSB_width+30;
float textarea_start_y = SB_start_y;
float textarea_width = 125;
float textarea_height = 300;

int selectedH,selectedS,selectedB = 0;

boolean mousePressedInSB = false;

void setup() {
  size(1024,768);
  background(0);
  
  colorMode(RGB,255);
  fill(255);
  textAlign(CENTER);
  textSize(32);
  text("Digital Color Converter", (width-1000)/2, 80, 1000, 50);
  textAlign(LEFT);
  textSize(16);
  
  createSB(selectedH);
  createSlider();
  createPreview(selectedH,selectedS,selectedB);
}

void draw() {
}

void mouseClicked() {
  if(isInH()) {
    selectedH = int(HSB_colorWidth*((mouseX-SB_start_x)/HSB_width));
    createSB(selectedH);
    createPreview(selectedH,selectedS,selectedB);
  }
}

void mousePressed() {
  if(isInSB()) {
    mousePressedInSB = true;
    selectedS = int(HSB_colorWidth*((mouseX-SB_start_x)/HSB_width));
    selectedB = int(HSB_colorWidth*(1 - (mouseY-SB_start_y)/SB_height));
    createPreview(selectedH,selectedS,selectedB);
  }
  else mousePressedInSB= false;
}

void mouseDragged() {
  if(mousePressedInSB) {
    selectedS = int(HSB_colorWidth*((mouseX-SB_start_x)/HSB_width));
    selectedB = int(HSB_colorWidth*(1 - (mouseY-SB_start_y)/SB_height));
    
    if(selectedS>HSB_colorWidth) selectedS=int(HSB_colorWidth);
    if(selectedS<0) selectedS=0;
    if(selectedB>HSB_colorWidth) selectedB=int(HSB_colorWidth);
    if(selectedB<0) selectedB=0;
    
    createPreview(selectedH,selectedS,selectedB);
  }
}



void createSB(int H) {
  println("Rendering...");
  colorMode(HSB,int(HSB_colorWidth));
  color pointColor;
  float pointX, pointY;
  for(float S=0; S<HSB_colorWidth; S+=(HSB_colorWidth/HSB_width)) {
    for(float B=0; B<HSB_colorWidth; B+=(HSB_colorWidth/SB_height)) {
      //println(H,S,B);
      pointColor = color(H,S,B);
      stroke(pointColor);
      pointX = SB_start_x +S*(HSB_width/HSB_colorWidth);
      pointY = SB_start_y+SB_height -B*(SB_height/HSB_colorWidth);
      point(pointX,pointY);
    }
  }
  println("Completed");
}

void createSlider() {
  colorMode(HSB,int(HSB_colorWidth));
  color lineColor;
  float lineX;
  for(float H=0; H<HSB_colorWidth; H+=(HSB_colorWidth/HSB_width)) {
    lineColor = color(H,HSB_colorWidth,HSB_colorWidth);
    stroke(lineColor);
    lineX = SB_start_x +H*(HSB_width/HSB_colorWidth);
    line(lineX,SB_start_y+SB_height+20,lineX,SB_start_y+SB_height+30);
  }
}

void createPreview(int H,int S,int B) {
  colorMode(HSB,int(HSB_colorWidth));
  color boxColor = color(H,S,B);
  noStroke();
  fill(boxColor);
  rect(textarea_start_x,textarea_start_y+30*10,textarea_width,textarea_width);
  
  fill(0);
  rect(textarea_start_x,textarea_start_y,textarea_width,textarea_height);
  fill(HSB_colorWidth);
  
  text("H: "+int(selectedH/HSB_colorWidth*360)+"°",textarea_start_x,textarea_start_y,textarea_width,20);
  text("S: "+int(selectedS/HSB_colorWidth*100)+"%",textarea_start_x,textarea_start_y+30,textarea_width,20);
  text("B: "+int(selectedB/HSB_colorWidth*100)+"%",textarea_start_x,textarea_start_y+30*2,textarea_width,20);
  
  int[] rgb = HSB2RGB(selectedH,selectedS,selectedB);
  text("R: "+rgb[0],textarea_start_x,textarea_start_y+30*4,textarea_width,20);
  text("G: "+rgb[1],textarea_start_x,textarea_start_y+30*5,textarea_width,20);
  text("B: "+rgb[2],textarea_start_x,textarea_start_y+30*6,textarea_width,20);
  
  String hex = HSB2HEX(selectedH,selectedS,selectedB);
  text("HEX: #"+hex,textarea_start_x,textarea_start_y+30*8,textarea_width,20);
}


boolean isInSB() {
  return SB_start_x<=mouseX && mouseX<=SB_start_x+HSB_width && SB_start_y<=mouseY && mouseY<=SB_start_y+SB_height;
}
boolean isInH() {
  return SB_start_x<=mouseX && mouseX<=SB_start_x+HSB_width && SB_start_y+SB_height+20<=mouseY && mouseY<=SB_start_y+SB_height+30;
}


int[] HSB2RGB(int H, int S, int B) {
  int[] rtnRGB = {0,0,0};
  float fH = float(H)/HSB_colorWidth*360;
  float fS = float(S)/HSB_colorWidth;
  float fB = float(B)/HSB_colorWidth;
  
  // Convert H
  if((0<=fH && fH<=60) || (300<fH && fH<=360)) {//R_MAX
    rtnRGB[0] = 255;
    if((0<=fH && fH<=60)) rtnRGB[1] = int(255*fH/60); //Calc G
    else rtnRGB[2] = int(255*(60-(fH-300))/60); //Calc B
  }
  if(60<fH && fH<=180) {//G_MAX
    rtnRGB[1]=255;
    if(60<fH && fH<=120) rtnRGB[0] = int(255*(60-(fH-60))/60); //Calc R
    else rtnRGB[2] = int(255*(fH-120)/60); //Calc B
  }
  if(180<fH && fH<=300) {//B_MAX
    rtnRGB[2]=255;
    if(180<fH && fH<=240) rtnRGB[1] = int(255*(60-(fH-180))/60); //Calc G
    else rtnRGB[0] = int(255*(fH-300)/60);//Calc R
  }
  
  
  // Convert S & B
  for(int i=0; i<3; i++) {
    //S
    float sLeft = 255 - rtnRGB[i];
    rtnRGB[i] += int(sLeft*(1-fS));
    
    //B
    rtnRGB[i] = int(rtnRGB[i]*fB);
  }
  
  return rtnRGB;
}

String HSB2HEX(int H, int S, int B) {
  return RGB2HEX(HSB2RGB(H,S,B));
}

String RGB2HEX(int[] rgb) {
  String rtnHEX = "";
  for(int i=0; i<3; i++) {
    rtnHEX += hex(rgb[i],2);
  }
  return rtnHEX;
}
