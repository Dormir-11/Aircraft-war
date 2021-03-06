
Plane player;

Button playBut,yesBut,noBut;
Bg bg1,bg2;
Boss boss;

ArrayList<Bullet> bullets=new ArrayList<Bullet>();
ArrayList<Enemy> enemys=new ArrayList<Enemy>();
ArrayList<BossBullet> bbts=new ArrayList<BossBullet>();

int creatEnemyFrequency;

PImage gameBg,gameBg1,playImg,coinImg,skillImg,gameOverImg,BossImg;
PImage []enemyImg=new PImage[5];
float []enemySize=new float[5];
PImage []explosionImg=new PImage[3];
PImage fullHeart,halfHeart,emptyHeart; 
PImage []itemImg=new PImage[4];
PImage []planeImg=new PImage[2]; 
float []planeSize=new float[2];

float btSpeed,BGspeed,enemySpeedReduce;

int gameState;
int coins;
boolean gameOver,bossFlag;

void init(){
  gameState=1;
  btSpeed=5;
  gameOver=false;
  coins=0;
  BGspeed=1;
  enemySpeedReduce=0.3;
  bossFlag=false;  
  
  playBut=new Button(width/2,height/2,180,60);
  yesBut=new Button(width/4-50,height/5*3,80,40);
  noBut=new Button(width/4*3-50,height/5*3,80,40);
  bg1=new Bg(width/2,height/2);
  bg2=new Bg(width/2,-height/2);
  player=new Plane();
  boss=new Boss();
  
  creatEnemyFrequency=20;
  
  enemys.clear();
  bullets.clear();
  bbts.clear();
}
void setup(){
  size(600,800);
  imageMode(CENTER);
  gameBg=loadImage("bg1.png");//600*800
  gameBg1=loadImage("bg2.png");//600*800
  playImg=loadImage("playButton.png");//167*75
  fullHeart=loadImage("fullHeart.png");//37*29
  halfHeart=loadImage("halfHeart.png");
  emptyHeart=loadImage("emptyHeart.png");
  coinImg=loadImage("coin.png");
  skillImg=loadImage("skill.png");
  planeImg[0]=loadImage("plane1.png");//61*73
  planeImg[1]=loadImage("plane2.png");//45*49
  planeSize[0]=61/2;
  planeSize[1]=45/2;
  gameOverImg=loadImage("game over.png");//2155*612
  BossImg=loadImage("Boss.png");
  for(int i=0;i<5;i++){
    enemyImg[i]=loadImage("enemy"+i+".png");
  }
  for(int i=0;i<3;i++){
    explosionImg[i]=loadImage("explosion"+i+".png");
  }
  for(int i=0;i<4;i++){
    itemImg[i]=loadImage("item"+i+".png");
  }
  enemySize[0]=enemySize[3]=enemySize[4]=45/2;
  enemySize[1]=enemySize[2]=25/2;
  init();
}

void draw(){
  if(gameState==1){//开始界面
   
    displayBg();
    player.display();
    startPage();
  }else if(gameState==2){//游戏界面
    displayBg();
    if(gameOver){
      gameOverPage();
    }else{
      if(bossFlag){
        bossPage();
      }else{
         creatEnemy();
         enemyMove();
      }
      bulletMove();
      player.display();
      player.creatBullet();
      player.skill1();
      player.skill2();
    }
  }
    
  ts();
}

void startPage(){//开始页面
  //background(#e7e6e1);
  image(playImg,playBut.x,playBut.y);
  if(playBut.ImgCheck()){
    gameState=2;
    frameCount=0;
  }
}

void bossPage(){//boss页面
  boss.display();
  for(int i=0;i<bbts.size();i++){
    bbts.get(i).display();
    if(bbts.get(i).flag)bbts.remove(i);
  }
}

void gameOverPage(){//游戏结束页面
  if(boss.hp>0){
    image(gameOverImg,width/2,height/3,400,120);
  }else{
    textSize(50);
    fill(255,0,0);
    text("YOU WIN !",width/2-150,height/2);
  }
  yesBut.display("YES");
  noBut.display("NO");
  if(yesBut.check()){
    init();
    gameState=2;
  }
  if(noBut.check()){
    init();
  }
}

void displayBg(){//游戏中的背景
  if(coins>=1000){//金币大于1000转到boss界面
    bossFlag=true;
    enemys.clear();
  }
  //两个背景交替显示
  bg1.display();
  bg2.display();
  
  if(gameState==1)return ;
  
  //HP
  for(int i=0;i<4;i++){
    image(emptyHeart,20+i*40,30);
  }
  switch(player.hp){
    case 8:
      image(fullHeart,20+40*3,30);
    case 7:
      image(halfHeart,20+40*3,30);
    case 6:
      image(fullHeart,20+40*2,30);
    case 5:
      image(halfHeart,20+40*2,30);
    case 4:
      image(fullHeart,20+40,30);
    case 3:
      image(halfHeart,20+40,30);
    case 2:
      image(fullHeart,20,30);
    case 1:
      image(halfHeart,20,30);
      break;
  }
  
  //COINS
  image(coinImg,width-150,30);
  textSize(35);
  fill(255,0,0);
  text(coins,width-120,40);
  
  //SP
  textSize(30);
  fill(255,0,0);
  text("SP",20,height-30);
  noFill();
  stroke(255,0,0);
  strokeWeight(4);
  rect(55,height-50,105,20);
  noStroke();
  if(player.sp==10){
    fill(#fd3a69);
  }else if(player.sp>4){
    fill(#ffd369);
  }else{
    fill(#32e0c4);
  }
  for(int i=0;i<player.sp;i++){
    rect(60+(i)*10,height-45,7,10);
  }
  
  if(player.skillFlag2){//skill2
    fill(#f4f9f9,80);
    rect(0,0,width,height);
  }
}

void bulletMove(){//子弹移动
  for(int i=0;i<bullets.size();i++){
    bullets.get(i).display();
    if(bullets.get(i).flag)bullets.remove(i);
  }
}

void enemyMove(){//敌人移动
  for(int i=0;i<enemys.size();i++){
    enemys.get(i).display();
    enemys.get(i).explosionAnimation();
    enemys.get(i).displayItem();
    if(!enemys.get(i).availabeFlag)enemys.remove(i);
  }
}

void creatEnemy(){//创建敌人
  if(frameCount%creatEnemyFrequency!=0)return ;
  Enemy e=new Enemy();
  enemys.add(e);
}



//-----------------------------------飞机------------------------------------
class Plane{
  float x,y,skx,sky,sksz,skt1,skt2;

  int shootSpeed,opt,hp,sp,powr;

  boolean skillFlag1,skillFlag2,shootFlag;
  Plane(){
    x=width/2;
    y=height-100;
    opt=0;
    powr=1;
    skillFlag1=false;
    skillFlag2=false;
    shootSpeed=10;
    hp=8;
    sp=0;
    shootFlag=true;
  }
  void display(){
    x=mouseX;
    y=mouseY;
    image(planeImg[opt],x,y);
    if(hp<=0)gameOver=true;
  }
  
  void creatBullet(){//生成子弹
    if(!shootFlag)return ;
    if(frameCount%shootSpeed!=0)return;
    switch(powr){
      case 5:
         Bullet t4=new Bullet(x+20,y-planeSize[opt]/2);
         bullets.add(t4);
      case 4:
         Bullet t3=new Bullet(x-20,y-planeSize[opt]/2);
         bullets.add(t3);
      case 3:
      Bullet t2=new Bullet(x+10,y-planeSize[opt]/2);
         bullets.add(t2);
      case 2:
         Bullet t1=new Bullet(x-10,y-planeSize[opt]/2);
         bullets.add(t1);
      case 1:
         Bullet t=new Bullet(x,y-planeSize[opt]/2);
         bullets.add(t);
    }
  }
  void skill1(){//第一个技能
    if(frameCount>skt1+300){
      shootFlag=true;
    }
    if(!skillFlag1&&sp==10&&mousePressed&&opt==1){
      skx=x;
      sky=y;
      skillFlag1=true;
      sksz=1;
      sp-=10;
      shootFlag=false;
      skt1=frameCount;
    }
    if(skillFlag1){
      fill((#a6f6f1),10);
      //strokeWeight();
      stroke(#a6f6f1);
      ellipse(skx,sky,sksz,sksz);
      //image(skillImg,skx,sky,sksz,sksz);
      sksz+=10;
      for(Enemy e:enemys){//判断敌人是否在技能范围内
        if(!e.expFlag&&dist(e.x,e.y,skx,sky)<sksz/2){
           e.expFlag=true;
           e.recode=frameCount;
        }
      }
      if(sksz>=height){
        skillFlag1=false;
      }
    }
  }
  void skill2(){//减速技能
    if(frameCount>skt2+300){
      skillFlag2=false;
    }
    if(!skillFlag2&&sp==10&&mousePressed&&opt==0){
       skillFlag2=true;
       skt2=frameCount;
       sp-=10;
    }
  }
}



//-------------------------------------玩家子弹-----------------------------------
class Bullet{
  float x,y,sz;
  boolean flag;
  Bullet(float tx,float ty){
    x=tx;
    y=ty;
    sz=5;
    flag=false;
  }
  void display(){
    if(flag)return ;
    noStroke();
    fill(255,0,0);
    rect(x,y,sz,sz*1.5);
    y-=btSpeed;
    if(y<-10)flag=true;
    for(Enemy e:enemys){
      if(!e.expFlag&&dist(x+2.5,y,e.x,e.y)<enemySize[e.opt]){//玩家子弹命中敌人
        e.expFlag=true;
        e.recode=frameCount;
        flag=true;
        coins+=10;
        if(player.sp<10)player.sp+=1;
        break;
      }
    }
    if(dist(x,y,boss.x,boss.y)<boss.sz/2){//子弹越界
      boss.hp--;
      flag=true;
    }
  }
}

//--------------------------------------敌人-----------------------------
class Enemy{
  float x,y,speed,osp;
  int opt,recode,iopt;
  boolean flag,expFlag,availabeFlag;
  Enemy(){
    opt=int(random(5));
    iopt=int(random(4));
    x=random(30,width-30);
    y=-random(50,100);
    osp=random(1,5);
    flag=false;//
    expFlag=false;//是否爆炸
    availabeFlag=true;
  }
  void display(){
    if(flag||expFlag)return ;
    image(enemyImg[opt],x,y);
    if(!player.skillFlag2){//敌人受玩家技能2的影响
      speed=osp;
    }else{
      speed=enemySpeedReduce*osp;//减速
    }
    y+=speed;
    if(y>height+50){//敌人越界
      flag=true;
      availabeFlag=false;
      return;
    }
    if(!expFlag&&dist(x,y,player.x,player.y)<planeSize[player.opt]+20){//敌人碰到玩家
      
      player.hp--;
      expFlag=true;
      recode=frameCount;
      availabeFlag=false;
    }
  }
  void explosionAnimation(){//爆炸的动画
    if(!expFlag)return ;
    if(frameCount-recode<5){//前五帧显示第一张爆炸图片
      image(explosionImg[0],x,y);
    }else if(frameCount-recode<10){//中间五帧显示第二张爆炸图片
      image(explosionImg[1],x,y);
    }else if(frameCount-recode<15){//最后五帧显示第三张爆炸图片
      image(explosionImg[2],x,y);
    }else{//回收flag=true
      flag=true;
    }
  }
  void displayItem(){//敌人转化为道具
    if(!flag)return ;
    image(itemImg[iopt],x,y);
    y+=BGspeed;
    if(dist(x,y,player.x,player.y)<planeSize[player.opt]){
      availabeFlag=false;
      switch(iopt){
        case 0://绿色
          if(player.hp<8)player.hp+=1;
        break;
        case 1://蓝色
          player.sp+=2;
          if(player.sp>10)player.sp=10;
        break;
        case 2://橙色
          coins+=100;
        break;
        case 3://紫色
          if(player.powr<5)player.powr+=1;
        break;
      }
      
    }
  }
}

class Bg{//背景的类
  float x,y,speed;
  Bg(float tx,float ty){
    x=tx;
    y=ty;
  }
  void display(){
    image(gameBg1,x,y);
    image(gameBg,x,y);
    y+=BGspeed;
    if(y>height+height/2){
      y=-height/2;
    }
  }
}

//----------------------------------------Boss-----------------------------------

class Boss{
  float x,y,speed,osp,sz;
  int shootFre,hp;
  Boss(){
     x=width/2;
     y=-200;
     osp=0.5;
     sz=200;
     shootFre=20;
     hp=50;
  } 
  
  void display(){
    image(BossImg,x,y,sz,sz);
    if(!player.skillFlag2){//玩家技能二的影响
      speed=osp;
    }else{
      speed=enemySpeedReduce*osp;//减速
    }
    if(y<height/2)y+=speed;
    if(frameCount%20==0){//boss发射子弹
      BossBullet b=new BossBullet(x,y,player.x,player.y);
      bbts.add(b);
    }
    if(dist(x,y,player.x,player.y)<sz/2){//boos碰到玩家
      player.hp-=2;
    }
    if(hp<=0){
      gameOver=true;
    }
  }
}

class BossBullet{//boss的子弹类
   float x,y,tarx,tary,sz,speed;
   boolean flag;
   BossBullet(float _x,float _y,float _tarx,float _tary){
     x=_x;
     y=_y;
     tarx=_tarx;
     tary=_tary;
     sz=5;
     flag=false;
     speed=4;
   }
   void display(){
     if(x==tarx&&y==tary){
       flag=true;
       return ;
     }
     noFill();
     stroke(#b8b5ff);
     ellipse(x,y,sz,sz); 
     float dx =  tarx - x; 
     float dy = tary - y; 
     float dd = sqrt(dx * dx + dy * dy); 
    if (dd < speed){ 
        x = tarx; 
        y = tary; 
     }else{ 
        x += dx * (speed / dd); 
        y += dy * (speed / dd); 
     } 
    if(dist(x,y,player.x,player.y)<planeSize[player.opt]){//子弹碰到玩家
       player.hp--;
       flag=true;
    }
   }
}

//--------------------------------------按钮-------------------------------

class Button{
  float x,y,w,h,stkW,sz;
  boolean flag;
  color butCol,strokeCol,txtCol;
  Button(float tx,float ty,float tw,float th){
    x=tx;
    y=ty;
    h=th;
    w=tw;
    flag=false;
    butCol=color(255);
    strokeCol=color(0);
    txtCol=color(0);
    sz=25;
  }
  boolean check(){
    if(flag)return true;
     if(mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+h&&mousePressed){
       flag=true;
       return true;
     }
     return false;
  }
  boolean ImgCheck(){
    if(flag)return true;
     if(mouseX>x-w/2&&mouseX<x+w/2&&mouseY>y-h/2&&mouseY<y+h/2&&mousePressed){
       flag=true;
       return true;
     }
     return false;
  }
  void display(String s){
    stroke(0);
    textSize(sz);
    fill(butCol);
    rect(x,y,w,h);
    fill(txtCol);
    text(s,x,y+sz);
  }
}

void mouseWheel(MouseEvent event) {//鼠标滚轮更换飞机
  if(gameState==1)return ;
  float e = event.getCount();
  if(e>0)player.opt=1;
  else player.opt=0;
  //println(e);
}

void ts(){
  if(frameCount%30!=0)return;
  //println(enemys.size());
  println(boss.hp);
}
