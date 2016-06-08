XIncludeFile "Rull.pbi"

Global MainForm
Global MainArea
Global BackCanvas
Global DrawCanvas
Global ZoomFactor.d=1 ; Le zomm de départ est à 100%
Global *myRullH,*myRullV
Global DrawWithPxl,DrawHeightPxl
Global W=210,H=297 ; Format A4
Structure Guide
    Value.i
    Type.i
    *IdGrid
EndStructure
Global NewList myGuide.Guide()
; Déclaration des procédures
Declare Exit()
Declare EventRull(*IdRull,Value,LeftButtonUp.b,myData)
Declare CalculDrawPxlSize()
Declare Resize()
Declare CanvasEvent()
Declare DrawLine()
MainForm=OpenWindow(#PB_Any,0,0,800,600,"teste",#PB_Window_SizeGadget|#PB_Window_SystemMenu)
; Création d'une aire de positionement
MainArea=ScrollAreaGadget(#PB_Any,0,0,WindowWidth(MainForm),WindowHeight(MainForm),WindowWidth(MainForm)-5,WindowHeight(MainForm)-5,50)
; Création de la règle horisontale
*myRullH=Rull::Create(W,@EventRull())
; Création de la règle Verticale
*myRullV=Rull::Create(H,@EventRull(),1)
; Création de la surface de dessin
DrawCanvas=CanvasGadget(#PB_Any,0,0,100,100,#PB_Canvas_Keyboard)
CloseGadgetList() ; ferme le ScrollArea

; Repositionne les canvas
Resize()
; Mise ne place des callback
BindGadgetEvent(DrawCanvas,@CanvasEvent())
BindEvent(#PB_Event_CloseWindow,@Exit(),MainForm)
Procedure Exit()
    Rull::FreeRull(*myRullH)
    Rull::FreeRull(*myRullV)
    End
EndProcedure
Procedure EventRull(*IdRull,Value,LeftButtonUp.b,myData)
    Select *IdRull
        Case *myRullH
            If myData>-1
;                 Debug myData
                ChangeCurrentElement(myGuide(),myData)
                If Value>0
                    myGuide()\Value=Value
                    DrawLine()
                    ProcedureReturn 
                Else
                    Rull::RemoveGrid(*myRullH,myGuide()\IdGrid)
                    DeleteElement(myGuide())
                    DrawLine()
                    ProcedureReturn 
                EndIf
            EndIf
            If  LeftButtonUp
                AddElement(myGuide())
                With myGuide()
                    \Type=0
                    \Value=Value
                    \IdGrid=Rull::AddGrid(*myRullH,\Value,@myGuide(),RGBA(0, 0, 128, 100),1)
                    DrawLine()
                    ProcedureReturn 
                EndWith
            EndIf
        Case *myRullV
            If myData>-1
                ChangeCurrentElement(myGuide(),myData)
                If Value>0 ; On modifie la position
                    myGuide()\Value=Value
                    DrawLine()
                    ProcedureReturn 
                Else ; on supprime le guide
                    Rull::RemoveGrid(*myRullV,myGuide()\IdGrid)
                    DeleteElement(myGuide())
                    DrawLine()
                    ProcedureReturn 
                EndIf
            EndIf
            If  LeftButtonUp   
                AddElement(myGuide())
                With myGuide()
                    \Type=1
                    \Value=Value
                    \IdGrid=Rull::AddGrid(*myRullV,\Value,@myGuide(),RGBA(0, 0, 128, 100),1)
                    DrawLine()
                    ProcedureReturn 
                EndWith
            EndIf
    EndSelect
EndProcedure
Procedure CalculDrawPxlSize()
    StartVectorDrawing(CanvasVectorOutput(DrawCanvas,#PB_Unit_Millimeter))
    ScaleCoordinates(ZoomFactor,ZoomFactor,#PB_Coordinate_User)
    DrawWithPxl=ConvertCoordinateX(W,0,#PB_Coordinate_User,#PB_Coordinate_Device)
    DrawHeightPxl=ConvertCoordinateY(0,H,#PB_Coordinate_User,#PB_Coordinate_Device)
    StopVectorDrawing()
EndProcedure
Procedure Resize()
    Protected W,H,X,Y,RullHW,RullHH,RullVW,RullVH
    ; Calcul en Pxl la taille de la zone de dessin
    CalculDrawPxlSize()
    ; Modifie le Zoom des règles
    Rull::SetZoom(*myRullH,ZoomFactor)
    Rull::SetZoom(*myRullV,ZoomFactor)
    ; Récupère les dimentions des règles
    RullHW=Rull::GetPxlWidth(*myRullH)
    RullHH=Rull::GetPxlHeight(*myRullH)
    RullVW=Rull::GetPxlWidth(*myRullV)
    RullVH=Rull::GetPxlHeight(*myRullV)
    ; Calcul le centrage
    If (DrawWithPxl+RullHH)<=GadgetWidth(MainArea)-50
        SetGadgetAttribute(MainArea,#PB_ScrollArea_InnerWidth,GadgetWidth(MainArea)-50)
        X=(GadgetWidth(MainArea)/2)-((DrawWithPxl+RullHH)/2)
    Else
        SetGadgetAttribute(MainArea,#PB_ScrollArea_InnerWidth,(DrawWithPxl+RullHH)+50)
        X=0
    EndIf
    If (DrawHeightPxl+RullW)<=GadgetHeight(MainArea)-50
        SetGadgetAttribute(MainArea,#PB_ScrollArea_InnerHeight,GadgetHeight(MainArea)-50)
        Y=(GadgetHeight(MainArea)/2)-((DrawHeightPxl+RullW)/2)
    Else
        SetGadgetAttribute(MainArea,#PB_ScrollArea_InnerHeight,(DrawHeightPxl+RullW)+50)
    EndIf
    ; Repositionne les règles
    Rull::SetPosition(*myRullH,X+RullVW,Y)
    Rull::SetPosition(*myRullV,X,Y+RullHH)
    ;Repositionne la zone de dessin
    X+RullVW
    Y+RullHH
    ResizeGadget(DrawCanvas,X,Y,DrawWithPxl,DrawHeightPxl)
    DrawLine()
EndProcedure
Procedure CanvasEvent()
    Protected WDelta
    Select EventType()
        Case #PB_EventType_MouseWheel ; Gestion du zoom
            If GetGadgetAttribute(DrawCanvas,#PB_Canvas_Modifiers)=#PB_Canvas_Control
                WDelta= GetGadgetAttribute(DrawCanvas,#PB_Canvas_WheelDelta)
                If WDelta>0
                    ZoomFactor=ZoomFactor+0.1
                    Resize()
                EndIf
                If WDelta<0
                    If ZoomFactor>0.25
                        ZoomFactor=ZoomFactor-0.1
                        Resize()
                    EndIf
                EndIf
            EndIf
    EndSelect
EndProcedure
Procedure DrawLine()
    Protected X,Y,W,H
    StartVectorDrawing(CanvasVectorOutput(DrawCanvas,#PB_Unit_Millimeter))
    ScaleCoordinates(ZoomFactor,ZoomFactor,#PB_Coordinate_User)
    VectorSourceColor($FFFFFFFF)
    FillVectorOutput()
    VectorSourceColor($FFCD0000)
    ForEach myGuide()
        With myGuide()
            Select \Type
                Case 0
                    X=\Value
                    Y=0
                    H=GadgetHeight(DrawCanvas)
                    MovePathCursor(X,Y)
                    AddPathLine(0,H,#PB_Path_Relative)    
                Case 1
                    Y=\Value
                    X=0
                    W=GadgetWidth(DrawCanvas)
                    MovePathCursor(X,Y)
                    AddPathLine(W,0,#PB_Path_Relative)
            EndSelect
            DotPath(0.4,2)
            ResetPath()
        EndWith
    Next
    StopVectorDrawing()
EndProcedure

Repeat:WaitWindowEvent():ForEver
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 23
; FirstLine = 7
; Folding = -HA9
; EnableXP