import hypermedia.video.*;
import java.awt.*;


OpenCV opencv;

//resolution de la camera
int w = 640;
int h = 480;
int threshold = 80;//regler la sensibilite de detection


float QuantiteMouvement=0; 

int numPixels;
float[] baricentre= {
  0,0
};
float[] oldbaricentre= {
  0,0
};
float[] centre= {
  (w/2),(h/2)
};
float[] derivee= {
  0,0
};

float total_area;





void init_motion() {

  opencv = new OpenCV( this );

  opencv.capture(w,h);
  numPixels=w*h;
}


void  MotionDetect() {



  ///lit l'image courante
  opencv.read();


  image( opencv.image(),0,0,320, 240 );	            // RGB image

  opencv.absDiff();
  opencv.threshold(threshold);


  //detecte les  blobs
  Blob[] blobs = opencv.blobs( 100, w*h/3, 7, true );

  ///memorise l'image courante pour l'analyse suivante
  opencv.remember();


  total_area=0;


  for( int i=0; i<blobs.length; i++ ) {///pour toutes les zonnes détectées

    Rectangle bounding_rect	= blobs[i].rectangle;
    float area = blobs[i].area;

    Point centroid = blobs[i].centroid;
    Point[] points = blobs[i].points;

    float barre=area*(blobs[i].centroid.x-(w/2));

    baricentre[0] = baricentre[0]+ barre;
    baricentre[1] += area*(blobs[i].centroid.y-(h/2));
    total_area += area;
  }


  ///bilan de la detection = mise à niveau du baricentre

  if (blobs.length>0) {
    baricentre[0]=(baricentre[0]/total_area)/blobs.length;
    baricentre[1]=(baricentre[1]/total_area)/blobs.length;
  }
  else {
    baricentre[0]=0;
    baricentre[1]=0;
  }

  float[] newderivee= {
    0,0
  };
  ///mise àjour de la derivée du mouvemlent
  newderivee[0]=(baricentre[0]-oldbaricentre[0])/14;
  newderivee[1]=(baricentre[1]-oldbaricentre[1])/14; 



  ///oldbaricentre est le baricentre maorti
  oldbaricentre[0]=oldbaricentre[0]+(newderivee[0]);     
  oldbaricentre[1]=oldbaricentre[1]+(newderivee[1]);

  ///memorise la derivee amortie
  derivee[0]= derivee[0]+ (newderivee[0]-derivee[0])/3;
  derivee[1]= derivee[1]+ (newderivee[1]-derivee[1])/3;





  ///dessin du vecteur de mouvement
  stroke(0, 250, 0);
  noFill();
  ellipseMode(CENTER);
  strokeWeight(1);

  //reperes
  ellipse(160,120,8, 8);

  line(0,120,20,120);
  line(300,120,320,120);
  line(160,0,160,20);
  line(160,220,160,240);

  //affichages mouvements
  println(total_area);
  int dia=int(total_area*500/numPixels);
  if(dia>240) {
    dia=240;
  }
  stroke(30,0,250);
  fill(20,10,250,100);
  ellipse(160,120, dia, dia);
  noFill();

  stroke(0, 250, 0);


  //vecteur du baricentre
  line(160, 120, oldbaricentre[0]+160, oldbaricentre[1]+120);
  fill(0,250,0);
  ellipse(oldbaricentre[0]+160, oldbaricentre[1]+120,4, 4);

  stroke(230,20,0);
  line( oldbaricentre[0]+160, oldbaricentre[1]+120,derivee[0]+oldbaricentre[0]+160, oldbaricentre[1]+120+derivee[1]);


  fill(30,0,250);
  ///affichage des résultats de la détection
  QuantiteMouvement=total_area/numPixels;
  text("mvt="+QuantiteMouvement, 10, 265);
  fill(0,255,0);
  text("baricentre=["+oldbaricentre[0]+":"+oldbaricentre[1]+"]", 10, 280);
  fill(230,20,0);
  text("derivee=["+derivee[0]+":"+derivee[0]+"]", 10, 295);
}




public void stop() {
  opencv.stop();


  //arrêt des moteurs
  super.stop();
}



