//Bonus

class Bonus {
  
  //Declaration des paramètres de base de bonus
  int x, y, l, h;
  color c = color(#FFE239);
  int vitesse;

  //Constructeur de bonus
  Bonus() {
    x=0;
    y=int(random(height));  //la hauteur des bonus varie
    l=20;
    h=25;
    vitesse = int(random(5,25));  //la vitesse des bonus varie
  }

/////////////////////////////////////////////

//affichage 
  void display() {
    x+=vitesse;
    fill(c);
    ellipse(x, y, l, h); 
  }
  
/////////////////////////////////////////////

//intersection
  void touche(Rectangle visiteur) {
    if(visiteur.x > x && visiteur.x< x+l && visiteur.y >y && visiteur.y < y+h) {
      fill(#36a9e1);
      text("+5",x,y);  //si on attrape un bonus, "+5" apparait
      
      // quand on touche un bonus, on gagne 5 points 
      p=p+5;  //le score augmente de 5 points
      println(p);  //affichage du score

     }     
    }
}

