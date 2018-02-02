// The file format of the measured data is converted to a nice format for
// scilab. A file constains several measurements / experiments that
// are separated by the "start" keyword. These are split into several files.
// File structure of measured data of two experiments
//      start
//      ###    ####    ####     ####     ####
//      ###    ####    ####     ####     ####
//      ...
//      ###    ####    ####     ####     ####
//      ###    ####    ####     ####     ####
//      start
//      ###    ####    ####     ####     ####
//      ###    ####    ####     ####     ####
//      ...
//      ###    ####    ####     ####     ####
//      ###    ####    ####     ####     ####

// Data is split in two text files with structure: (Var# = variable name)
//      Var1   Var2    Var3     Var4     Var5
//      ###    ####    ####     ####     ####
//      ###    ####    ####     ####     ####
//      ...
//      ###    ####    ####     ####     ####
//      ###    ####    ####     ####     ####

clc;
clear;
deb = 1; // write some debug messages to the console if 1

// laad fucties in
// exec(pwd() + "\voltage_to_value.sce");

// The variable names are hard coded in this script in the variable "header"
header = msprintf("Time\tTorque\tCurrent\tVoltage\tCadans\tSpeed");

//-----------------------------------------------------------------------------
// Ask for filename and start progressbar
// If the progressbar keeps going to long
// probably something went wrong, have a look in the scilab console for errors
//-----------------------------------------------------------------------------

fileName = x_dialog("Filename to read from raw_data folder?", "sample1.txt")
progressBar = progressionbar("Data omzetten en opslaan.");

// Open file, save data to scilab variable and close it again
filePath = pwd() + "\raw_data\" + fileName;
fid = mopen(filePath, "r");
if (fid == -1)
  error("Cannot open file for reading.");
end
data = mgetl(fid);
mclose(fid);

//-----------------------------------------------------------------------------
// Count the number of measurents / parts
//-----------------------------------------------------------------------------
partIndex = 0;
numMeas = 0;
for i=1:size(data,1)
    if data(i) == 'start' then
        numMeas = numMeas + 1;
        partIndex(numMeas, 1) = i;
    end
end

if deb then
    message = msprintf("Found %d different measuremnts.", size(partIndex,1));
    disp(message);
    disp("These are saved in the following locations:");
end

//-----------------------------------------------------------------------------
// Different measuremnts (called parts) saved in separate files, each with a header
// containing variable names
// the name consists of the original name of the file + a second part indication
// to which measuremnt it belongs, with the format "_part_#.txt"
//-----------------------------------------------------------------------------
// filePath for output files
name = strsubst(fileName, ".txt", "");
path = pwd() + "\converted_data\";

partIndex(numMeas + 1,1) = size(data,1) + 1;
rit = 0;
for i=1:numMeas
    // create filename
    partName = msprintf("_part_%d.txt", i);
    partName = path + name + partName;
    // open new file
    rfid = mopen(partName, "w");
    // write variable names
    mputl(header, rfid);
    // write data
    mputl(data( partIndex(i,1)+1 : partIndex(i+1,1)-1 ), rfid);
    mclose(rfid);
    if deb then
        disp(partName);
    end
end

close(progressBar);


