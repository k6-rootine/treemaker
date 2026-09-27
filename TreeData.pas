{ Cette unité stoke les informations d'une espèce d'arbre ainsi que ses différentes phases de croissance (de la graine à la maturité)}
unit TreeData;

interface

const 
    MAX_VERTICAL = 30; //< Nombre de lignes de la grille d'affichage d'une phase.
    MAX_HORIZONTAL = 80; //< Nombre de colonnes de la grille d'affichage d'une phase.
    MAX_PHASE = 10; //< Nombre maximal de phases de croissance pour un arbre.

type 
    { Couleur d'un caractère affiché à l'écran
    
    L'ordre des valeurs correspond exactement à celui de l'unité @code(crt) afin de pouvoir convertir directement une @code(TColor) en argument de @code(TextColor).}
    TColor = (BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, BROWN, LIGHT_GRAY, DARK_GRAY, 
    LIGHT_BLUE, LIGHT_GREEN, LIGHT_CYAN, LIGHT_RED, LIGHT_MAGENTA, YELLOW, WHITE);

    { Une "image" de l'arbre à un instant donné de sa croissance. Chaque case de la grille contient un caractère (@code(elem)) et sa couleur (@code(couleur)). }
    TPhase = record 
        elem: Array[1..MAX_VERTICAL, 1..MAX_HORIZONTAL] of Char;
        colour: Array[1..MAX_VERTICAL, 1..MAX_HORIZONTAL] of TColor;
    end;

    { Une espèce d'arbre complète, avec son nom, sa description, et l'ensemble de ses phases de croissance. }
    TTree = record 
        speciesName, description: String;
        phase: Array[1..MAX_PHASE] of TPhase;
        nbPhase: LongInt;
    end;

{   
    @abstract(Construit une phase vide.)
    Toutes les cases de la grille contiennent une espace @code(' '), de couleur @code(BLACK) par défaut.
    @returns(Une nouvelle @code(TPhase) vierge.)
}
function initialisePhase(): TPhase;


{ 
    @abstract(Retourne le caractère affiché à une position de la phase.)
    @param(phase La phase consultée.)
    @param(horizontal Colonne consultée.)
    @param(vertical Ligne consultée.)
    @returns(Le caractère à cette position, ou une espece si la position est en dehors de la grille.)
}
function getElement(phase: TPhase; horizontal, vertical: LongInt): Char;


{
    @abstract(Modifie le caractère affiché à une position de la phase.)
    Ne fait rien si la position est en dehors de la grille.
    @param(phase La phase modifiée (passée par référence))
    @param(horizontal Colonne modifiée.)
    @param(vertical Ligne modifiée.)
    @param(character Nouveau caractère à afficher à cette position.)
}
procedure setElement(var phase: TPhase; horizontal, vertical: LongInt; character: Char);


{ 
    @abstract(Retourne la couleur du caractère à une position de la phase.)
    @param(phase La phase consultée.)
    @param(horizontal Colonne consultée.)
    @param(vertical Ligne consultée.)
    @returns(La couleur à cette position, ou @code(RED) si la position est en dehors de la grille.)
}
function getColor(phase: TPhase; horizontal, vertical: LongInt): TColor;


{
    @abstract(Modifie la couleur du caractère à une position de la phase.)
    @param(phase La phase modifiée (passée par référence).)
    @param(horizontal Colonné modifiée.)
    @param(vertital Ligne modifiée.)
    @param(color Nouvelle couleur à appliquer à cette position.)
}
procedure setColor(var phase: TPhase; horizontal, vertical: LongInt; color: TColor);


{
    @abstract(Construit un arbre vide.)
    Le nom et la description sont vides, et aucune phase n'est encore définie (@code(nbPhase) = 0). Chaque case du tableau @code(phase) est pré-initialisée (phase vide).
    @returns(Un nouvel arbre vierge.)
}
function initialiseTree(): TTree;


{
    @abstract(Retourne le nom de l'espèce de l'arbre.)
    @param(tree L'arbre consulté.)
    @returns(Le nom de l'espèce.)
}
function getSpeciesName(tree: TTree): String;


{
    @abstract(Modifie le nom de l'espèce de l'arbre.)
    @param(tree L'arbre modifié (passé par référence).)
    @param(speciesName Nouveau nom de l'espèce.)
}
procedure setSpeciesName(var tree: TTree; speciesName: String);


{
    @abstract(Retourne la description de l'espèce de l'arbre.)
    @param(tree L'arbre consulté.)
    @returns(La description de l'espèce.)
}
function getDescription(tree: TTree): String;


{
    @abstract(Modifie la description de l'espèce de l'arbre.)
    @param(tree L'arbre modifié (passé par référence).)
    @param(description Nouvelle description de l'espèce.)
}
procedure setDescription(var tree: TTree; description: String);


{
    @abstract(Retourne une phase de croissance de l'arbre.)
    @param(tree L'arbre consulté.)
    @param(phaseNb Numéro de la phase demandée.)
    @returns(La phase demandée, ou une phase vide si @code(phaseNb) est en dehors de l'intervalle [1, @code(nbPhase)].)
}
function getPhase(tree: TTree; phaseNb: LongInt): TPhase;


{
    @abstract(Définit une phase de croissance de l'arbre.)
    Si @code(phaseNb) dépasse @code(nbPhase), celui-ci est automatiquememt étendu jusqu'à @code(phaseNb). Ne fait rien si @code(phaseNb) dépasse @code(MAX_PHASE).
    @param(tree L'arbre modifié (passé par référence).)
    @param(phaseNb Numéro de la phase définie.)
    @param(phase Contenu de la phase à enregistrer.)
}
procedure setPhase(var tree: TTree; phaseNb: LongInt; phase: TPhase);


{
    @abstract(Retourne le nombre total de phases de croissance définies.)
    @param(tree L'arbre consulté.)
    @returns(Le nombre de phases actuellement définies pour cet arbre.)
}
function getNbPhases(tree: TTree): LongInt;


implementation
function initialisePhase(): TPhase;
var 
    vertical, horizontal: LongInt;
begin 
    for vertical := 1 to MAX_VERTICAL do
    begin
        for horizontal := 1 to MAX_HORIZONTAL do
        begin
            initialisePhase.elem[vertical][horizontal] := ' ';
            initialisePhase.colour[vertical][horizontal] := TColor(0);
        end;
    end;
end;

function getElement(phase: TPhase; horizontal, vertical: LongInt): Char;
begin
    if (horizontal >= 1) and (horizontal <= MAX_HORIZONTAL) and
       (vertical >= 1) and (vertical <= MAX_VERTICAL) then
        getElement := phase.elem[vertical][horizontal]
    else
        getElement := ' ';
end;

procedure setElement(var phase: TPhase; horizontal, vertical: LongInt; character: Char);
begin
    if (horizontal >= 1) and (horizontal <= MAX_HORIZONTAL) and
       (vertical >= 1) and (vertical <= MAX_VERTICAL) then
        phase.elem[vertical][horizontal] := character;
end;

function getColor(phase: TPhase; horizontal, vertical: LongInt): TColor;
begin
    if (horizontal >= 1) and (horizontal <= MAX_HORIZONTAL) and
       (vertical >= 1) and (vertical <= MAX_VERTICAL) then
        getColor := TColor(phase.colour[vertical][horizontal])
    else
        getColor := Red;
end;

procedure setColor(var phase: TPhase; horizontal, vertical: LongInt; color: TColor);
begin
    if (horizontal >= 1) and (horizontal <= MAX_HORIZONTAL) and
       (vertical >= 1) and (vertical <= MAX_VERTICAL) then
        phase.colour[vertical][horizontal] := color;
end;

function initialiseTree(): TTree;
var
    phaseNb: LongInt;
begin
    initialiseTree.speciesName := '';
    initialiseTree.description := '';
    initialiseTree.nbPhase := 0;

    for phaseNb := 1 to MAX_PHASE do
        initialiseTree.phase[phaseNb] := initialisePhase();
end;

function getSpeciesName(tree: TTree): String;
begin
    getSpeciesName := tree.speciesName;
end;

procedure setSpeciesName(var tree: TTree; speciesName: String);
begin
    tree.speciesName := speciesName;
end;

function getDescription(tree: TTree): String;
begin
    getDescription := tree.description;
end;

procedure setDescription(var tree: TTree; description: String);
begin
    tree.description := description;
end;

function getPhase(tree: TTree; phaseNb: LongInt): TPhase;
begin
    if (phaseNb >= 1) and (phaseNb <= tree.nbPhase) then
        getPhase := tree.phase[phaseNb]
    else
        getPhase := initialisePhase();
end;

procedure setPhase(var tree: TTree; phaseNb: LongInt; phase: TPhase);
begin
    if (phaseNb >= 1) and (phaseNb <= MAX_PHASE) then
    begin
        if phaseNb > tree.nbPhase then
            tree.nbPhase := phaseNb;

        tree.phase[phaseNb] := phase;
    end;
end;

function getNbPhases(tree: TTree): LongInt;
begin
    getNbPhases := tree.nbPhase;
end;

end.