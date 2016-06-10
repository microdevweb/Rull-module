# Rull-module

For PureBasic 

Voici un petit module que je fais pour mon usage (règle en mm)

Version  1.1

Les fonctions sont les suivantes:

* Rull::Create(mySize,*Callback,Direction.i=0)
  * mySize Largueur ou hauteur suivant la direction
  * *Callback La procédure qui sera appelée lors d'une action sur la règle
  * Direction .0 Horizontal ; 1 Vertical
  * Renvoi l'adresse mémoire de la liste
* SetZoom(IdRull,ZoomFactor.d=1)
  * IdRull adresse mémoire de la liste
  * ZoomFactor le facteur de zoom (ex: 1 100% 0.5 50%)
* GetPxlWidth(IdRull) retourne la largeur en pxl
* GetPxlHeight(IdRull) retourne la hauteur en pxl
* SetPosition(IdRull,X,Y) modifie la position de la règle
* AddGrid(IdRull,Value,,Color.d,size.d)
  * IdRull adresse mémoire de la liste
  * Value la valeur ou sera ajouté le taquet en mm
  * myData une valeur de votre choix qui sera retournée le taquet est modifié (-1) si pas de modification
  * Color la couleur du taquet en RGBA
  * size taille du taquet (ex: 0.8,1,1.2)
  * Renvoi l'adresse mémoire de la liste
* RemoveGrid(IdRull,IdGrid)
  * IdRull l'adresse mémoire de la règle
  * IdGrid l'adresse mémoire du taquet
* FreeRull(IdRull) Libère la mémoire en supprimant la règle (à appelé à la fermeture de la fenêtre par exemple)
  * IdRull l'adresse mémoire de la règle
* ClearGrid(IdRull) Efface tous les taquet de la règle
  * IdRull l'adresse mémoire de la règle
* SetGridValue(IdRull,IdGrid,Value) modifie la valeur d'un taquet
  * IdRull l'adresse mémoire de la règle
  * IdGrid l'adresse mémoire du taquet
  * Value la nouvelle valeur du taquet

La procédure CallBack doit être renseignée comme ceci

Exemple: EventRull(*IdRull,Value,LeftButtonUp.b,myData)
* *IdRull index de la liste
* Value La valeur sélectionnée sur la règle en mm
* LeftButtonUp #True si le bouton gauche de la souris est relâche ou en cas de simple clique
* myData la valeur renseignée avec AddGrid ou -1 si aucune modification

Remarque: Pour zoomer dans le teste maintenez CTRL et molette de la souris
