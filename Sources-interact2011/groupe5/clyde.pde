/*
                    Melie Ling et Marie Lamouret
 
 
                       Workshop interactivite
 
                               CLYDE 
 
 
 */

/////////////////////////////////////////////

//Librairies

//OpenCV
OpenCV opencv;

// Librairie Minim
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
AudioPlayer player;
Minim minim;


//Declaration des variables

//declaration du score 
float p;

//declaration du temps
int tps = 0;

//declaration de la typographie
PFont police;

//declaration de l'image
PShape s;

//tableau des obstacles
Obstacle []embuches=new Obstacle[13];
int []ox= {
  -50,-800,-1600,-2650,-4200,-400,-2300,-3400,-4600,-1200,-1900,-3000,-3900
};
int []oy= {
  0,50,20,10,10,75, 75,75,75,220,220,220,220
};
int []tailles= {
  50,50,50,50,50,50,50,50,50,20,20,20,20
};

//tableau des bonus
ArrayList mesBonus = new ArrayList();


/////////////////////////////////////////////

void setup() {
  
  //minim
  minim = new Minim(this);
  player = minim.loadFile("music.mp3");
  
  // initialisation du score à zéro
  p=0;
  
  //creation de tous les obstacles
  for(int j=0;j<embuches.length;j++) {
    embuches[j]=new Obstacle(ox[j], oy[j], tailles[j],tailles[j], color(#FFFFFF, 1));
  }

  //creation du plan de travail
  size(320, 240);  
  init_motion();
  smooth();

  //chargement de la typographie
  police = loadFont("EurostileRegular-48.vlw");
  textFont(police, 40);

  //chargement de l'image
  s=loadShape("pinky.svg");
}

/////////////////////////////////////////////

void draw() {
 
  //titre et decompte
  
  if ((millis()-tps)>0 && (millis()-tps)<10000) {
    background(#36a9e1);
    fill(255);

    if ((millis()-tps)>1000 && (millis()-tps)<6000) {
      text("CLYDE", 105, 130);
    }

    else if ((millis()-tps)>6000 && (millis()-tps)<7000) {
      text("3", 150, 130);
    }

    else if ((millis()-tps)>7000 && (millis()-tps)<8000) {
      text("2", 150, 130);
    }

    else if ((millis()-tps)>8000 && (millis()-tps)<9000) {
      text("1", 150, 130);
    }

    else if((millis()-tps)>9000 && (millis()-tps)<10000) {
      fill(#f85898);
      noStroke();
      text("GO!", 140, 130);
      player.play();
    }
  } 

  //debut du jeu
  if ((millis()-tps)>10000) {
    
    //bonus    
     int monTirage = int(random(20));
     if(monTirage == 10) {
       mesBonus.add(new Bonus());
       println("bonus");
     }
    
    background(0);
    MotionDetect();
    noStroke();
    
    //creation, affichage des bonus
    for (int i =0; i< mesBonus.size(); i++) { 
      Bonus bonus = (Bonus) mesBonus.get(i);
      bonus.display();
      if(bonus.x > width)mesBonus.remove(i);
    }
    
    //affichage des embuches
      for(int j=0;j<embuches.length;j++) {
        embuches[j].display();
      }
    }
    
    //si le score est negatif, game over
    if(p<0) {
        fill(0);
        rect(0, 0, 320, 240);
        fill(#ffffff);
        text("Game Over",75, 120);
      }
  }

/////////////////////////////////////////////

  void stop() {
    opencv.stop();
    super.stop();
  }

