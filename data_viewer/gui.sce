clear;
clearglobal;
clc;

// Variables to cache information while viewing data
global param dataPath fileList currentFile labelList  currentLabelX currentLabelY;
labelList = ['No data'];

// Variables for gui layout
margin = 0.02;
elementWidth = 0.25;
elementHeight = 0.05;
listHeigth = 0.3;
axesWidth = 1 - 7 * margin - elementWidth;
axesHeight = 1 - 6 * margin;
color0 = [1, 0.8, 0.3]; // Background color window
color1 = [1, 0.9, 0.4]; // Background color file browser

// Load file list of all data in folder "converted_data"
dataPath = pwd() + "\converted_data"; // pwd() directory of this script
fileList = ls(dataPath);

//-----------------------------------------------------------------------------
// Draw GUI
//-----------------------------------------------------------------------------

// Create empty figure
f = figure(..
    'figure_position',[400,50],..
    'figure_size',[800,700],..
    'auto_resize','on',..
    'BackgroundColor',color0,..
    'figure_name',..
    'Data viewer'..
);

// Delete menu bar, I don't use it for this application
delmenu(f.figure_id,gettext('File'))
delmenu(f.figure_id,gettext('Edit'))
delmenu(f.figure_id,gettext('?'))
delmenu(f.figure_id,gettext('Tools'))
//toolbar(f.figure_id,'off')

// Create empty axes to plot data that the user wants to view
axes = newaxes();
axes.margins = [ 0 0 0 0];
axes.axes_bounds = [6 * margin + elementWidth, margin, axesWidth, axesHeight];
axes.filled = "off";

// Add text to explane the function of different elements in the gui
//-----------------------------------------------------------------------------
// Title of file browser
listBoxTitle=uicontrol(..
f,'Style','text',..
'unit','normalized',..
'Position',[margin,8*margin + 3*elementHeight + 2*listHeigth,elementWidth + margin,elementHeight],..
'HorizontalAlignment','center',..
'FontUnits', 'normalized', ..
'FontSize', elementHeight/1.1,...
'String','Select a file to view',..
'BackgroundColor',color0..
);

// Title of x-axis selector list box
listBoxTitle=uicontrol(..
    f,'Style','text',..
    'unit','normalized',..
    'Position',[margin, 4*margin + 2*elementHeight + listHeigth,elementWidth/2,elementHeight],..
    'HorizontalAlignment','center',..
    'FontUnits', 'normalized', ..
    'FontSize', elementHeight/1.7,...
    'String','X-axis variable (horizontal)',..
    'BackgroundColor',color0..
);

// Title of y-axis selector list box
listBoxTitle=uicontrol(..
    f,'Style','text',..
    'unit','normalized',..
    'Position',[2*margin + elementWidth/2, 4*margin + 2*elementHeight + listHeigth,elementWidth/2,elementHeight],..
    'HorizontalAlignment','center',..
    'FontUnits', 'normalized', ..
    'FontSize', elementHeight/1.7,...
    'String','Y-axis variable (vertical)',..
    'BackgroundColor',color0..
);

// Lists to select something (listbox)
//-----------------------------------------------------------------------------
// Geef de lijst met bestanden weer in een "listbox"
listbox=uicontrol(f,'Style','listbox',..
'unit','normalized',..
'BackgroundColor',color1,..
'ForegroundColor',[-1,-1,-1],..
'HorizontalAlignment','left',..
'Max',[1],'Min',[0],.. // Maximum on file can be selected at the same time
'Position',[margin,7*margin + 3*elementHeight + listHeigth,elementWidth + margin,listHeigth],...
'String',fileList,..
'Value',[0],.. // No files are selected at startup
'Tag','listbox',..
'Callback','listBox_callback(listbox, listboxX, listboxY)'..
);

// Lisbox voor keuze variabele op x en y as
listboxX=uicontrol(..
    f,'Style','listbox',..
    'unit','normalized',..
    'BackgroundColor',color1,..
    'ForegroundColor',[-1,-1,-1],..
    'HorizontalAlignment','left',..
    'Max',[1],'Min',[0],.. // Maximum on variable can be selected
    'Position',[margin,5*margin + 3*elementHeight,elementWidth/2,listHeigth/1.4],...
    'String',labelList,..
    'Value',[1],.. // No variable is selected at startup
    'Tag','listboxX',..
    'Callback','listboxX_callback(listboxX)'..
);

listboxY=uicontrol(..
    f,'Style','listbox',..
    'unit','normalized',..
    'BackgroundColor',color1,..
    'ForegroundColor',[-1,-1,-1],..
    'HorizontalAlignment','left',..
    'Max',[1],'Min',[0],.. // Maximum on variable can be selected
    'Position',[2*margin + elementWidth/2,5*margin + 3*elementHeight,elementWidth/2, listHeigth/1.4],...
    'String',labelList,..
    'Value',[1],.. // No variable is selected at startup
    'Tag','listboxY',..
    'Callback','listboxY_callback(listboxY)'..
);

// Othe user input (checkbox, pushbutton)
//-----------------------------------------------------------------------------
// Checkbox to choos wheter we have to plot dots or a line
checkboxPlotMarker=uicontrol(..
    f,'Style','checkbox',..
    'unit','normalized',..
    'Position',[margin,3*margin + 2*elementHeight,elementWidth,elementHeight],..
    'Max',[1],'Min',[0],..
    'String','Volle lijn tekenen',..
    'HorizontalAlignment','center',..
    'BackgroundColor',color0..
);

// Button to update plot
listBoxTitle=uicontrol(..
    f,'Style','pushbutton',..
    'unit','normalized',..
    'Position',[margin,2*margin + elementHeight,elementWidth,elementHeight],..
    'String','Update plot',..
    'HorizontalAlignment','center',..
    'FontUnits', 'normalized', ..
    'FontSize', elementHeight/1.1,...
    'BackgroundColor',color1,..
    "callback", "plotButton_callback(listbox, listboxX, listboxY, checkboxPlotMarker)"..
);

// Button to save current data to scilab data file
listBoxTitle=uicontrol(..
    f,'Style','pushbutton',..
    'unit','normalized',..
    'Position',[margin,margin,elementWidth,elementHeight],..
    'String','Save data',..
    'HorizontalAlignment','center',..
    'FontUnits', 'normalized', ..
    'FontSize', elementHeight/1.1,...
    'BackgroundColor',color1,..
    "callback", 'saveData_callback()'..
);

//-----------------------------------------------------------------------------
// Callback functions
//-----------------------------------------------------------------------------
function listBox_callback(listbox, listboxX, listboxY)
    // Load data of selected file in listbox (file selector)
    global param dataPath fileList currentFile labelList currentLabelX currentLabelY;
    currentFile = fileList(listbox.Value);
    winId = progressionbar("Load data.")
    readData(currentFile);
    listboxX.string = labelList;
    listboxX.value = [1];
    currentLabelX = labelList(listboxX.value);
    listboxY.string = labelList;
    listboxY.value = [1];
    currentLabelY = labelList(listboxY.value);
    close(winId);
endfunction

function listboxX_callback(listboxX)
    // Load data for x-axis from x-axis listbox selector
    global param dataPath fileList currentFile labelList currentLabelX currentLabelY;
    currentLabelX = labelList(listboxX.value);
endfunction

function listboxY_callback(listboxY)
    // Load data for y-axis from y-axis listbox selector
    global param dataPath fileList currentFile labelList currentLabelX currentLabelY;
    currentLabelY = labelList(listboxY.value);
endfunction

function plotButton_callback(listbox, listboxX, listboxY, checkboxPlotMarker)
    // Update plot axes based on selected data and line style
    global param dataPath fileList currentFile labelList currentLabelX currentLabelY;
    
    marker = '.';
    if(checkboxPlotMarker.value)
        marker = '-';
    end
    
    a = gca();
    a.auto_clear= "on"; // Clear axes before plotting the new data
    plot(param(:,listboxX.value), param(:,listboxY.value), marker);
    
    a.x_label.text = currentLabelX;
    a.x_label.font_size = 4;
    a.y_label.text = currentLabelY;
    a.y_label.font_size = 4;
endfunction

function readData(fileName)
    global param dataPath fileList currentFile labelList;
    
    fid = mopen(dataPath + "\" + currentFile)
    data = mgetl(fid);
    mclose(fid);
    
    labelList = strsplit(data(1), ascii(9));
    
    // first row in data file containts the labels
    // so there's on row less data than the numbers of lines in the file
    n_row = size(data, 1)-1;
    n_col = size(labelList,1);
    param = zeros(n_row, n_col);
    for i=1:n_row
        temp = evstr(data(i+1)); // first row in data file containts the labels
        for j=1:n_col
            param(i, j) = temp(j);
        end
    end
endfunction

function saveData_callback()
    // Export currently viewed data as a scilab data file "saved_data.sod"
    global param currentFile;
    name = strsubst(currentFile, ".txt", ".sod");
    save(name, param);
    msg = msprintf('Data of the selected file is saved as..
    ""%s"" \nYou can load this data again with the command ..
    load(""%s"")', name, name);
    messagebox(msg);
endfunction
