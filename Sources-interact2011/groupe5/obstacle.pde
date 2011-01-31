//Obstacle

class Obstacle {

  //Declaration des paramètres de base de l'obstacle
  int x;
  int y;
  int vitesseX;
  int vitesseY;
  color couleur;
  int th,tv;  //taille horizontale, taille verticale

  Rectangle maForme;
  PShape forme;

/////////////////////////////////////////////

  //Constructeur de l'obstacle
  Obstacle (int nouvX, int nouvY, int tailleH, int tailleV,color tcouleur) {
    x = nouvX;
    y = nouvY;
    couleur = tcouleur;
    th=tailleH;
    tv=tailleV;

    maForme=new Rectangle(x, y, th, tv);

    vitesseX = 20;
    vitesseY = 20;

    forme=loadShape("pinky.svg");
  }

/////////////////////////////////////////////

  //Dessin de l'obstacle
  void display() {

    x += vitesseX;

    maForme.y=y;
    maForme.x=x;
    
    //boucle
    if (x > 4600) {
      x = -70;
    }
    
    //couleur et forme
    fill(couleur);
    rect(x, y, th, tv);

    //image
    shape(forme, x, y, th, tv);
  }

/////////////////////////////////////////////

//intersection
  void touche(Rectangle visiteur) {
    if(visiteur.x > maForme.x && visiteur.x< maForme.x+maForme.width && visiteur.y > maForme.y && visiteur.y < maForme.y+maForme.height) {
      fill(#f85898);
      text("-3",x,y);  //si on touche un obstacle, "-3" apparait
      
      // quand on touche un obstacle, on perd 3 points
      p=p-3;  //le score diminue de 3 points
      println(p);  //affichage du score
    }
  }
}

