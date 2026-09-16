unit TreeData;

interface

const 
    MAX_VERTICAL = 100;
    MAX_HORIZONTAL = 100;
    MAX_PHASE = 50;

type 
    TPhase = record 
        elem: Array[1..MAX_VERTICAL][1..MAX_HORIZONTAL] of Char;
        colour: Array[1..MAX_VERTICAL][1..MAX_HORIZONTAL] of Byte;
    end;

    TTree = record 
        speciesName, description: String;
        phase: Array[1..MAX_PHASE] of TPhase;
        nbPhase: LongInt;
    end;

implementation

end.