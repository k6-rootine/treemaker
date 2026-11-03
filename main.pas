program Main;

uses
    Crt,
    SysUtils,
    TreeData;


type
    TTreeFile = file of TTree;


{ =========================================================
  GENERAL UTILITIES
  ========================================================= }

procedure pauseProgram();
begin
    WriteLn;
    Write('Press ENTER to continue...');
    ReadLn;
end;


function colorToString(color: TColor): String;
begin
    case color of
        Red:
            colorToString := 'Red';

        Green:
            colorToString := 'Green';

        Blue:
            colorToString := 'Blue';

        Brown:
            colorToString := 'Brown';
    end;
end;


function stringToColor(text: String; var color: TColor): Boolean;
begin
    text := LowerCase(Trim(text));

    if text = 'red' then
    begin
        color := Red;
        stringToColor := True;
    end
    else if text = 'green' then
    begin
        color := Green;
        stringToColor := True;
    end
    else if text = 'blue' then
    begin
        color := Blue;
        stringToColor := True;
    end
    else if text = 'brown' then
    begin
        color := Brown;
        stringToColor := True;
    end
    else
        stringToColor := False;
end;


function colorToConsole(color: TColor): Byte;
begin
    case color of
        Red:
            colorToConsole := LightRed;

        Green:
            colorToConsole := LightGreen;

        Blue:
            colorToConsole := LightBlue;

        Brown:
            colorToConsole := 6;
    end;
end;


function removeQuotes(text: String): String;
begin
    text := Trim(text);

    if Length(text) >= 2 then
    begin
        if ((text[1] = '''') and
            (text[Length(text)] = '''')) or
           ((text[1] = '"') and
            (text[Length(text)] = '"')) then
        begin
            Delete(text, 1, 1);
            Delete(text, Length(text), 1);
        end;
    end;

    removeQuotes := Trim(text);
end;


function getDataFileName(speciesName: String): String;
begin
    getDataFileName := speciesName + '.dat';
end;


{ =========================================================
  TXT IMPORT
  ========================================================= }

function parseImportLine(
    line: String;
    var phaseNb: LongInt;
    var horizontal: LongInt;
    var vertical: LongInt;
    var character: Char;
    var color: TColor
): Boolean;

var
    comma1, comma2, comma3, comma4: LongInt;

    field1, field2, field3: String;
    field4, field5: String;

begin
    parseImportLine := False;

    comma1 := Pos(',', line);

    if comma1 = 0 then
        Exit;

    comma2 := Pos(',', Copy(line, comma1 + 1, Length(line)));

    if comma2 = 0 then
        Exit;

    comma2 := comma2 + comma1;

    comma3 := Pos(',', Copy(line, comma2 + 1, Length(line)));

    if comma3 = 0 then
        Exit;

    comma3 := comma3 + comma2;

    comma4 := Pos(',', Copy(line, comma3 + 1, Length(line)));

    if comma4 = 0 then
        Exit;

    comma4 := comma4 + comma3;


    field1 := Trim(
        Copy(line, 1, comma1 - 1)
    );

    field2 := Trim(
        Copy(
            line,
            comma1 + 1,
            comma2 - comma1 - 1
        )
    );

    field3 := Trim(
        Copy(
            line,
            comma2 + 1,
            comma3 - comma2 - 1
        )
    );

    field4 := Trim(
        Copy(
            line,
            comma3 + 1,
            comma4 - comma3 - 1
        )
    );

    field5 := Trim(
        Copy(
            line,
            comma4 + 1,
            Length(line)
        )
    );


    if not TryStrToInt(field1, phaseNb) then
        Exit;

    if not TryStrToInt(field2, horizontal) then
        Exit;

    if not TryStrToInt(field3, vertical) then
        Exit;


    field4 := removeQuotes(field4);

    if (Length(field4) = 2) and
       (field4[1] = '\') then
        Delete(field4, 1, 1);

    if Length(field4) <> 1 then
        Exit;

    character := field4[1];


    if not stringToColor(field5, color) then
        Exit;


    parseImportLine := True;
end;


function importTreeFromTextFile(
    var tree: TTree;
    fileName: String
): Boolean;

var
    fileData: TextFile;
    line: String;

    phaseNb: LongInt;
    horizontal: LongInt;
    vertical: LongInt;

    character: Char;
    color: TColor;

    phase: TPhase;

begin
    importTreeFromTextFile := False;


    if not FileExists(fileName) then
    begin
        WriteLn('Error: file does not exist: ', fileName);
        Exit;
    end;


    Assign(fileData, fileName);
    Reset(fileData);


    while not EOF(fileData) do
    begin
        ReadLn(fileData, line);

        line := Trim(line);

        if line = '' then
            Continue;


        if not parseImportLine(
            line,
            phaseNb,
            horizontal,
            vertical,
            character,
            color
        ) then
        begin
            WriteLn('Warning: invalid line ignored: ', line);
            Continue;
        end;


        if (phaseNb < 1) or
           (phaseNb > tree.nbPhase) then
        begin
            WriteLn(
                'Warning: invalid phase number: ',
                phaseNb
            );
            Continue;
        end;


        { Borders cannot contain elements }

        if (horizontal < 2) or
           (horizontal > MAX_HORIZONTAL - 1) or
           (vertical < 2) or
           (vertical > MAX_VERTICAL - 1) then
        begin
            WriteLn(
                'Warning: coordinate (',
                horizontal,
                ', ',
                vertical,
                ') is outside the drawing area.'
            );
            Continue;
        end;


        phase := getPhase(
            tree,
            phaseNb
        );


        setElement(
            phase,
            horizontal,
            vertical,
            character
        );

        setColor(
            phase,
            horizontal,
            vertical,
            color
        );


        setPhase(
            tree,
            phaseNb,
            phase
        );
    end;


    Close(fileData);

    importTreeFromTextFile := True;
end;


{ =========================================================
  TYPED .DAT FILE
  ========================================================= }

function saveTree(
    tree: TTree;
    fileName: String
): Boolean;

var
    treeFile: TTreeFile;

begin
    saveTree := False;

    Assign(treeFile, fileName);
    Rewrite(treeFile);

    Write(treeFile, tree);

    Close(treeFile);

    saveTree := True;
end;


function loadTree(
    fileName: String;
    var tree: TTree
): Boolean;

var
    treeFile: TTreeFile;

begin
    loadTree := False;


    if not FileExists(fileName) then
        Exit;


    Assign(treeFile, fileName);
    Reset(treeFile);


    if FileSize(treeFile) > 0 then
    begin
        Read(treeFile, tree);
        loadTree := True;
    end;


    Close(treeFile);
end;


{ =========================================================
  DRAWING
  ========================================================= }

procedure drawPhase(
    phase: TPhase;
    phaseNb: LongInt;
    totalPhases: LongInt
);

var
    horizontal, vertical: LongInt;

    character: Char;
    color: TColor;

begin
    ClrScr;


    WriteLn(
        'TREE EDITOR'
    );

    WriteLn(
        'Phase ',
        phaseNb,
        ' / ',
        totalPhases
    );

    WriteLn;


    WriteLn(
        'Drawable horizontal coordinates: 2..',
        MAX_HORIZONTAL - 1
    );

    WriteLn(
        'Drawable vertical coordinates:   2..',
        MAX_VERTICAL - 1
    );

    WriteLn;


    WriteLn(
        '[Left/Right] Change phase'
    );

    WriteLn(
        '[D] Draw   [S] Save   [Q] Finish'
    );

    WriteLn;


    for vertical := 1 to MAX_VERTICAL do
    begin
        for horizontal := 1 to MAX_HORIZONTAL do
        begin

            { Top and bottom borders }

            if (vertical = 1) or
               (vertical = MAX_VERTICAL) then
            begin
                TextColor(Crt.White);
                Write('-');
            end


            { Left and right borders }

            else if (horizontal = 1) or
                    (horizontal = MAX_HORIZONTAL) then
            begin
                TextColor(Crt.White);
                Write('|');
            end


            { Drawing area }

            else
            begin
                character := getElement(
                    phase,
                    horizontal,
                    vertical
                );

                color := getColor(
                    phase,
                    horizontal,
                    vertical
                );

                TextColor(
                    colorToConsole(color)
                );

                Write(character);
            end;
        end;

        WriteLn;
    end;


    TextColor(Crt.White);
end;


{ =========================================================
  ADD / MODIFY ONE ELEMENT
  ========================================================= }

procedure drawElement(
    var tree: TTree;
    currentPhase: LongInt
);

var
    horizontal, vertical: LongInt;

    characterInput: String;
    colorInput: String;

    character: Char;
    color: TColor;

    phase: TPhase;

begin
    WriteLn;


    repeat
        Write(
            'Horizontal coordinate (2..',
            MAX_HORIZONTAL - 1,
            '): '
        );

        ReadLn(horizontal);

    until (horizontal >= 2) and
          (horizontal <= MAX_HORIZONTAL - 1);


    repeat
        Write(
            'Vertical coordinate (2..',
            MAX_VERTICAL - 1,
            '): '
        );

        ReadLn(vertical);

    until (vertical >= 2) and
          (vertical <= MAX_VERTICAL - 1);


    repeat
        Write(
            'Character: '
        );

        ReadLn(characterInput);

    until Length(characterInput) = 1;


    character := characterInput[1];


    repeat
        Write(
            'Color (Red / Green / Blue / Brown): '
        );

        ReadLn(colorInput);

    until stringToColor(
        colorInput,
        color
    );


    phase := getPhase(
        tree,
        currentPhase
    );


    setElement(
        phase,
        horizontal,
        vertical,
        character
    );

    setColor(
        phase,
        horizontal,
        vertical,
        color
    );


    setPhase(
        tree,
        currentPhase,
        phase
    );
end;


{ =========================================================
  DRAWING SECTION
  ========================================================= }

procedure drawingSection(
    var tree: TTree;
    saveFileName: String
);

var
    currentPhase: LongInt;

    key: Char;
    extendedKey: Char;

    phase: TPhase;

    finished: Boolean;

begin
    currentPhase := 1;
    finished := False;


    while not finished do
    begin

        phase := getPhase(
            tree,
            currentPhase
        );


        drawPhase(
            phase,
            currentPhase,
            getNbPhases(tree)
        );


        key := ReadKey;


        { Arrow keys }

        if key = #0 then
        begin
            extendedKey := ReadKey;


            case extendedKey of

                { Left arrow }
                #75:
                begin
                    if currentPhase > 1 then
                        currentPhase := currentPhase - 1;
                end;


                { Right arrow }
                #77:
                begin
                    if currentPhase < getNbPhases(tree) then
                        currentPhase := currentPhase + 1;
                end;

            end;
        end


        else
        begin

            case UpCase(key) of

                'D':
                begin
                    drawElement(
                        tree,
                        currentPhase
                    );
                end;


                'S':
                begin
                    if saveTree(
                        tree,
                        saveFileName
                    ) then
                    begin
                        WriteLn;
                        WriteLn(
                            'Tree saved successfully to ',
                            saveFileName
                        );
                    end
                    else
                    begin
                        WriteLn;
                        WriteLn(
                            'Error while saving the tree.'
                        );
                    end;

                    pauseProgram;
                end;


                'Q':
                begin
                    finished := True;
                end;

            end;

        end;

    end;
end;


{ =========================================================
  CREATE NEW TREE
  ========================================================= }

procedure createNewTree();

var
    tree: TTree;

    speciesName: String;
    description: String;

    phaseCount: LongInt;
    phaseNb: LongInt;

    importChoice: String;
    textFileName: String;

    dataFileName: String;

    phase: TPhase;

begin
    ClrScr;


    WriteLn(
        '============================================================'
    );

    WriteLn(
        '                     CREATE NEW TREE'
    );

    WriteLn(
        '============================================================'
    );

    WriteLn;


    Write(
        'Species name: '
    );

    ReadLn(
        speciesName
    );


    Write(
        'Description: '
    );

    ReadLn(
        description
    );


    WriteLn;

    WriteLn(
        'Tree dimensions: ',
        MAX_HORIZONTAL,
        ' horizontal x ',
        MAX_VERTICAL,
        ' vertical.'
    );

    WriteLn(
        'Borders: horizontal 1 and ',
        MAX_HORIZONTAL,
        ', vertical 1 and ',
        MAX_VERTICAL,
        '.'
    );

    WriteLn(
        'Drawable area: horizontal 2..',
        MAX_HORIZONTAL - 1,
        ', vertical 2..',
        MAX_VERTICAL - 1,
        '.'
    );

    WriteLn;


    WriteLn(
        'Maximum number of phases: ',
        MAX_PHASE
    );


    repeat

        Write(
            'How many phases do you want? (1..',
            MAX_PHASE,
            '): '
        );

        ReadLn(
            phaseCount
        );

    until (phaseCount >= 1) and
          (phaseCount <= MAX_PHASE);


    tree := initialiseTree();


    setSpeciesName(
        tree,
        speciesName
    );

    setTreeDescription(
        tree,
        description
    );


    { Create requested phases }

    for phaseNb := 1 to phaseCount do
    begin
        phase := initialisePhase();

        setPhase(
            tree,
            phaseNb,
            phase
        );
    end;


    WriteLn;

    repeat

        Write(
            'Import the tree from a text file? (Y/N): '
        );

        ReadLn(
            importChoice
        );

    until (Length(importChoice) > 0) and
          ((UpCase(importChoice[1]) = 'Y') or
           (UpCase(importChoice[1]) = 'N'));


    if UpCase(importChoice[1]) = 'Y' then
    begin

        Write(
            'Enter the .txt file name: '
        );

        ReadLn(
            textFileName
        );


        if not importTreeFromTextFile(
            tree,
            textFileName
        ) then
        begin
            pauseProgram;
            Exit;
        end;

    end;


    dataFileName := getDataFileName(
        getSpeciesName(tree)
    );


    WriteLn;

    WriteLn(
        'Data file: ',
        dataFileName
    );

    WriteLn;

    pauseProgram;


    { Open editor }

    drawingSection(
        tree,
        dataFileName
    );


    { Save when editor is finished }

    if saveTree(
        tree,
        dataFileName
    ) then
    begin

        WriteLn;

        WriteLn(
            'Tree saved to ',
            dataFileName
        );

    end
    else
    begin

        WriteLn;

        WriteLn(
            'Error: unable to save tree.'
        );

    end;


    pauseProgram;
end;


{ =========================================================
  MODIFY TREE
  ========================================================= }

procedure modifyTree();

var
    tree: TTree;
    fileName: String;

begin
    ClrScr;


    WriteLn(
        '============================================================'
    );

    WriteLn(
        '                       MODIFY TREE'
    );

    WriteLn(
        '============================================================'
    );

    WriteLn;


    Write(
        'Enter the .dat file name: '
    );

    ReadLn(
        fileName
    );


    if not loadTree(
        fileName,
        tree
    ) then
    begin

        WriteLn;

        WriteLn(
            'Unable to load the tree file.'
        );

        pauseProgram;

        Exit;
    end;


    WriteLn;

    WriteLn(
        'Tree loaded successfully.'
    );

    WriteLn(
        'Species: ',
        getSpeciesName(tree)
    );

    WriteLn(
        'Description: ',
        getTreeDescription(tree)
    );

    WriteLn(
        'Number of phases: ',
        getNbPhases(tree)
    );


    pauseProgram;


    { Open editor }

    drawingSection(
        tree,
        fileName
    );


    { Save modified tree }

    if saveTree(
        tree,
        fileName
    ) then
    begin

        WriteLn;

        WriteLn(
            'Modified tree saved successfully.'
        );

    end
    else
    begin

        WriteLn;

        WriteLn(
            'Error: unable to save the tree.'
        );

    end;


    pauseProgram;
end;


{ =========================================================
  MAIN MENU
  ========================================================= }

procedure mainMenu();

var
    choice: String;

begin

    repeat

        ClrScr;


        WriteLn(
            '============================================================'
        );

        WriteLn(
            '                        TREE PROGRAM'
        );

        WriteLn(
            '============================================================'
        );

        WriteLn;


        WriteLn(
            '1. Create a new tree'
        );

        WriteLn(
            '2. Modify a tree file'
        );

        WriteLn(
            '3. Exit'
        );

        WriteLn;


        Write(
            'Choice: '
        );

        ReadLn(
            choice
        );


        case choice of

            '1':
            begin
                createNewTree();
            end;


            '2':
            begin
                modifyTree();
            end;


            '3':
            begin
                ClrScr;

                WriteLn(
                    'Goodbye!'
                );
            end;

        else

            begin
                WriteLn;
                WriteLn(
                    'Invalid choice.'
                );

                pauseProgram;
            end;

        end;

    until choice = '3';

end;


{ =========================================================
  PROGRAM
  ========================================================= }

begin
    mainMenu();
end.