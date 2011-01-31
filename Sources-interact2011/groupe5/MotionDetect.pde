//Declaration des librairies et des variables
import hypermedia.video.*;
import java.awt.*;

//resolution de la camera
int w = 320;
int h = 240;
int threshold = 90;//regler la sensibilite de detection

float QuantiteMouvement=0; 

int numPixels;

float total_area;

/////////////////////////////////////////////

void init_motion() {
  opencv = new OpenCV( this );
  opencv.capture(w,h);
  numPixels=w*h;
}

/////////////////////////////////////////////

void  MotionDetect() {

  //lit l'image courante
  opencv.read();

  image( opencv.image(),0,0,320, 240 );	  // RGB image
  opencv.absDiff();
  opencv.threshold(threshold);
  
  //detecte les  blobs
  Blob[] blobs = opencv.blobs( 100, w*h/3, 14, true );

  ///memorise l'image courante pour l'analyse suivante
  opencv.remember();

  total_area=0;

  for( int i=0; i<blobs.length; i++ ) {  //pour toutes les zones détectées

    Rectangle bounding_rect = blobs[i].rectangle;

    //dessine le blob
    stroke(250);
    noFill();    
    rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );

    //verifie l'intersection avec les obstacles
    for(int j=0;j<embuches.length;j++) {
      embuches[j].touche(bounding_rect);
    }
    
    //verifie l'intersection avec les bonus
    for (int k =0; k< mesBonus.size(); k++) { 
      Bonus bonus = (Bonus) mesBonus.get(k);
      bonus.touche(bounding_rect);

    }
  }
}
