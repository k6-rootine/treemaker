unit TreeData;

interface

const 
    MAX_VERTICAL = 30;
    MAX_HORIZONTAL = 80;
    MAX_PHASE = 10;

type 
    TColor = (Red, Green, Blue, Brown);
    TPhase = record 
        elem: Array[1..MAX_VERTICAL, 1..MAX_HORIZONTAL] of Char;
        colour: Array[1..MAX_VERTICAL, 1..MAX_HORIZONTAL] of TColor;
    end;

    TTree = record 
        speciesName, description: String;
        phase: Array[1..MAX_PHASE] of TPhase;
        nbPhase: LongInt;
    end;

function initialisePhase(): TPhase;
function getElement(phase: TPhase; horizontal, vertical: LongInt): Char;
procedure setElement(var phase: TPhase; horizontal, vertical: LongInt; character: Char);
function getColor(phase: TPhase; horizontal, vertical: LongInt): TColor;
procedure setColor(var phase: TPhase; horizontal, vertical: LongInt; color: TColor);

function initialiseTree(): TTree;
function getSpeciesName(tree: TTree): String;
procedure setSpeciesName(var tree: TTree; speciesName: String);
function getDescription(tree: TTree): String;
procedure setDescription(var tree: TTree; description: String);
function getPhase(tree: TTree; phaseNb: LongInt): TPhase;
procedure setPhase(var tree: TTree; phaseNb: LongInt; phase: TPhase);
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
            initialisePhase.colour[vertical][horizontal] := TColor(1);
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