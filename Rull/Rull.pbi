;************************************************************************************************************************
; Author : MicrodevWeb
; Project Name : PbPrint
; File Name : Rull.pbi
; Module : Rull
; Description : 
; Version : 1
;************************************************************************************************************************
DeclareModule Rull
    ;-* PUBLIC VARIABLE/LIST/MAP/CONSTANTE
    
    ;}
    ;-* PUBLIC DECLARATION
    Declare Create(mySize,*Callback,Direction.i=0)
    Declare SetZoom(IdRull,ZoomFactor.d=1)
    Declare GetPxlWidth(IdRull)
    Declare GetPxlHeight(IdRull)
    Declare SetPosition(IdRull,X,Y)
    Declare AddGrid(IdRull,Value,myData,Color.d,size.d)
    Declare RemoveGrid(IdRull,IdGrid)
    Declare FreeRull(IdRull)
    ;}
EndDeclareModule
Module Rull
    EnableExplicit
    ;-* LOCAL VARIABLE/LIST/MAP/CONSTANTE
    Structure Grid
        Value.i
        myData.i
        Color.d
        size.d
    EndStructure
    Structure Rull
        IdCanvas.i
        W.d
        H.d
        Direction.i
        ZoomFactor.d
        Value.d
        *CallBack
        Hover.b
        *IdHover
        List MyGrid.Grid()
    EndStructure
    Global NewList myRull.Rull()
    #BgColor=$FFDEDEDE
    #FgColor=$FF242424
    Global UnitFont=LoadFont(#PB_Any,"Arial",6,#PB_Font_HighQuality)
    Global ModeMove.b
    ;}
    ;-* LOCAL DECLARATION
    Declare Draw()
    Declare DrawUnitH()
    Declare DrawTxtUnitH()
    Declare DrawLineUniH()
    Declare DrawIndexValueH()
    Declare myEvent()
    Declare SendCallback(LeftUp.b)
    Declare DrawUnitV()
    Declare DrawTxtUnitV()
    Declare DrawLineUniV()
    Declare DrawIndexValueV()
    Declare DrawGridH()
    Declare IsHoverGridH(Value)
    Declare IsHoverGridV(Value)
    Declare DrawGridV()
    ;}
    ;-* PRIVATE PROCEDURE
    Procedure Draw()
        With myRull()
            StartVectorDrawing(CanvasVectorOutput(\IdCanvas,#PB_Unit_Millimeter))
            ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
            AddPathBox(0,0,\W,\H)
            VectorSourceColor(#BgColor)
            FillPath()
            Select \Direction
                Case 0
                    DrawUnitH()
                Case 1
                    DrawUnitV()
            EndSelect
            StopVectorDrawing()
        EndWith
    EndProcedure
    Procedure DrawUnitH()
        DrawTxtUnitH()
        DrawLineUniH()
;         If myRull()\Hover
;             DrawIndexValueH()
;         EndIf
        DrawGridH()
    EndProcedure
    Procedure DrawTxtUnitH()
        Protected N,X.d=1,Y.d=1,XT
        With myRull()
            VectorSourceColor(#FgColor)
            VectorFont(FontID(UnitFont))
            For N=0 To \W Step 10
                X=1*N
                Select N
                    Case 0
                        XT=0
                    Case \W
                        XT=\W-VectorTextWidth(Str(N))
                    Default
                        XT=X-(VectorTextWidth(Str(N))/2)
                EndSelect
                MovePathCursor(XT,Y)
                DrawVectorText(Str(N))
            Next
        EndWith
    EndProcedure
    Procedure DrawLineUniH()
        Protected N,S.d,H.d,X.d,Y.d,Decade.b=#False,R
        With myRull()
            VectorSourceColor(#FgColor)
            For N=0 To \W
                X=1*N
                Decade=#False
                If R=10
                    Decade=#True
                    R=0
                EndIf
                R+1
                If N=0  Or N=\W 
                    Decade=#True
                EndIf
                Select Decade
                    Case #True
                        S=0.4
                        H=\H*0.4
                        Y=\H-H
                    Default
                        S=0.2
                        H=\H*0.2
                        Y=\H-H
                EndSelect
                MovePathCursor(X,Y,#PB_Path_Relative)
                AddPathLine(0,H,#PB_Path_Relative)
                StrokePath(S)
            Next
        EndWith
    EndProcedure
    Procedure DrawIndexValueH()
        Protected X
        With myRull()
            VectorSourceColor(RGBA(255, 48, 48, 70))
            X=\Value
            MovePathCursor(X,0,#PB_Path_Relative)
            AddPathLine(0,GadgetHeight(\IdCanvas),#PB_Path_Relative)
            StrokePath(0.3)
        EndWith
    EndProcedure
    Procedure myEvent()
        With myRull()
            ChangeCurrentElement(myRull(),GetGadgetData(EventGadget()))
            Protected gMouseX=GetGadgetAttribute(EventGadget(),#PB_Canvas_MouseX)
            Protected gMouseY=GetGadgetAttribute(EventGadget(),#PB_Canvas_MouseY)
            Static  MX,MY,ClicOn.b=#False
            Select EventType()
                Case #PB_EventType_MouseEnter
                    \Hover=#True
                    SetGadgetAttribute(EventGadget(),#PB_Canvas_Cursor,#PB_Cursor_Cross)
                Case #PB_EventType_MouseLeave
                    \Hover=#False
                    Draw()
                Case #PB_EventType_MouseMove
                    Select \Direction
                        Case 0
                            StartVectorDrawing(CanvasVectorOutput(\IdCanvas,#PB_Unit_Millimeter))
                            ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
                            MX=ConvertCoordinateX(gMouseX,0,#PB_Coordinate_Device,#PB_Coordinate_User)
                            StopVectorDrawing()
                            If ModeMove And ClicOn
                                ChangeCurrentElement(myRull()\MyGrid(),myRull()\IdHover)
                                myRull()\MyGrid()\Value=MX
                                Draw()
                                \Value=MX
                                SendCallback(#False)
                                ProcedureReturn 
                            EndIf
                            If IsHoverGridH(MX)
                                SetGadgetAttribute(EventGadget(),#PB_Canvas_Cursor,#PB_Cursor_LeftRight)
                                ModeMove=#True
                            Else
                                SetGadgetAttribute(EventGadget(),#PB_Canvas_Cursor,#PB_Cursor_Cross)
                                ModeMove=#False
                            EndIf
                        Case 1
                            StartVectorDrawing(CanvasVectorOutput(\IdCanvas,#PB_Unit_Millimeter))
                            ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
                            MY=ConvertCoordinateY(0,gMouseY,#PB_Coordinate_Device,#PB_Coordinate_User)
                            StopVectorDrawing()
                            If ModeMove And ClicOn
                                ChangeCurrentElement(myRull()\MyGrid(),myRull()\IdHover)
                                myRull()\MyGrid()\Value=MY
                                \Value=MY
                                Draw()
                                SendCallback(#False)
                                ProcedureReturn 
                            EndIf
                            If IsHoverGridV(MY)
                                SetGadgetAttribute(EventGadget(),#PB_Canvas_Cursor,#PB_Cursor_UpDown)
                                ModeMove=#True
                            Else
                                SetGadgetAttribute(EventGadget(),#PB_Canvas_Cursor,#PB_Cursor_Cross)
                                ModeMove=#False
                            EndIf
                    EndSelect
                Case #PB_EventType_LeftClick
                    Select \Direction
                        Case 0
                            \Value=MX
                            Draw()
                            SendCallback(#True)
                        Case 1
                            \Value=MY
                            Draw()
                            SendCallback(#True)
                    EndSelect
                Case #PB_EventType_LeftButtonDown
                    ClicOn=#True
                Case #PB_EventType_LeftButtonUp
                    ClicOn=#False
            EndSelect
        EndWith
    EndProcedure
    Procedure SendCallback(LeftUp.b)
        Protected myData=-1
        With myRull()
            If \IdHover>-1
                ChangeCurrentElement(myRull()\MyGrid(),\IdHover)
                myData=\MyGrid()\myData
            EndIf
            CallFunctionFast(\CallBack,@myRull(),\Value,LeftUp,myData)
        EndWith
    EndProcedure
    Procedure DrawUnitV()
        DrawTxtUnitV()
        DrawLineUniV()
        DrawGridV()
    EndProcedure
    Procedure DrawTxtUnitV()
        Protected N,X.d=1,Y.d=1,YT,XR
        With myRull()
            VectorSourceColor(#FgColor)
            VectorFont(FontID(UnitFont))
            X=\W-VectorTextHeight(Str(N))
            RotateCoordinates(X,0,-90,#PB_Coordinate_User)
            For N=0 To \H Step 10
                Y=1*N
                Select N
                    Case 0
                        YT=0
                    Case \H
                        YT=\H-VectorTextWidth(Str(N))
                    Default
                        YT=Y-(VectorTextWidth(Str(N))/2)
                EndSelect
                MovePathCursor(-YT,-1.8)
                DrawVectorText(Str(N))
            Next
        EndWith
    EndProcedure
    Procedure DrawLineUniV()
        Protected N,S.d,H.d,X.d,Y.d,Decade.b=#False,R
        With myRull()
            ResetCoordinates(#PB_Coordinate_User)
            ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
            VectorSourceColor(#FgColor)
            X=\W
            For N=0 To \H
                Y=1*N
                Decade=#False
                If R=10
                    Decade=#True
                    R=0
                EndIf
                R+1
                If N=0  Or N=\H 
                    Decade=#True
                EndIf
                Select Decade
                    Case #True
                        S=0.4
                        H=\W*0.4
                    Default
                        S=0.2
                        H=\W*0.2
                EndSelect
                MovePathCursor(X,Y,#PB_Path_Relative)
                AddPathLine(-H,0,#PB_Path_Relative)
                StrokePath(S)
            Next
        EndWith
    EndProcedure
    Procedure DrawIndexValueV()
        Protected Y
        With myRull()
            VectorSourceColor(RGBA(255, 48, 48, 70))
            Y=\Value
            MovePathCursor(0,Y,#PB_Path_Relative)
            AddPathLine(GadgetWidth(\IdCanvas),0,#PB_Path_Relative)
            StrokePath(0.3)
        EndWith
    EndProcedure
    Procedure DrawGridH()
        Protected X.d
        With myRull()\MyGrid()
            ForEach myRull()\MyGrid()
                VectorSourceColor(\Color)
                X=\Value
                MovePathCursor(X,0,#PB_Path_Relative)
                AddPathLine(0,GadgetHeight(myRull()\IdCanvas),#PB_Path_Relative)
                StrokePath(\size)
            Next
        EndWith
    EndProcedure
    Procedure IsHoverGridH(Value)
        With myRull()\MyGrid()
            myRull()\IdHover=-1
            ForEach myRull()\MyGrid()
                If Value>=(\Value-(\size/2)) And Value<=(\Value+\size/2)
                    myRull()\IdHover=@myRull()\MyGrid()
                    ProcedureReturn #True
                EndIf
            Next
            ProcedureReturn #False
        EndWith
    EndProcedure
    Procedure IsHoverGridV(Value)
        With myRull()\MyGrid()
            myRull()\IdHover=-1
            ForEach myRull()\MyGrid()
                If Value>=(\Value-(\size/2)) And Value<=(\Value+\size/2)
                    myRull()\IdHover=@myRull()\MyGrid()
                    ProcedureReturn #True
                EndIf
            Next
            ProcedureReturn #False
        EndWith
    EndProcedure
    Procedure DrawGridV()
        Protected Y.d
        With myRull()\MyGrid()
            ForEach myRull()\MyGrid()
                VectorSourceColor(\Color)
                Y=\Value
                MovePathCursor(0,Y,#PB_Path_Relative)
                AddPathLine(GadgetWidth(myRull()\IdCanvas),0,#PB_Path_Relative)
                StrokePath(\size)
            Next
        EndWith
    EndProcedure
    ;}
    ;-* PUBLIC PROCEDURE
    Procedure Create(mySize,*Callback,Direction.i=0)
        Protected W,H
        With myRull()
            AddElement(myRull())
            \IdCanvas=CanvasGadget(#PB_Any,0,0,100,100)
            SetGadgetData(\IdCanvas,@myRull())
            BindGadgetEvent(\IdCanvas,@myEvent())
            \ZoomFactor=1
            \Direction=Direction
            \Value=0
            \CallBack=*Callback
            Select Direction
                Case 0
                    \W=mySize
                    \H=5
                    StartVectorDrawing(CanvasVectorOutput(\IdCanvas,#PB_Unit_Millimeter))
                    ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
                    W=ConvertCoordinateX(\W,1,#PB_Coordinate_User,#PB_Coordinate_Device)
                    H=ConvertCoordinateY(0,\H,#PB_Coordinate_User,#PB_Coordinate_Device)
                    StopVectorDrawing()
                    ResizeGadget(\IdCanvas,#PB_Ignore,#PB_Ignore,W,H)
                Case 1
                    \W=5
                    \H=mySize
                    StartVectorDrawing(CanvasVectorOutput(\IdCanvas,#PB_Unit_Millimeter))
                    ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
                    W=ConvertCoordinateX(\W,1,#PB_Coordinate_User,#PB_Coordinate_Device)
                    H=ConvertCoordinateY(0,\H,#PB_Coordinate_User,#PB_Coordinate_Device)
                    StopVectorDrawing()
                    ResizeGadget(\IdCanvas,#PB_Ignore,#PB_Ignore,W,H)
            EndSelect
            Draw()
            ProcedureReturn @myRull()
        EndWith
    EndProcedure
    Procedure SetZoom(IdRull,ZoomFactor.d=1)
        With myRull()
            Protected W,H
            If ChangeCurrentElement(myRull(),IdRull)=0
                MessageRequester("Rull Error","This Id "+Str(IdRull)+" does not exist")
                ProcedureReturn 
            EndIf
            \ZoomFactor=ZoomFactor
            Select \Direction
                Case 0
                    StartVectorDrawing(CanvasVectorOutput(\IdCanvas,#PB_Unit_Millimeter))
                    ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
                    W=ConvertCoordinateX(\W,1,#PB_Coordinate_User,#PB_Coordinate_Device)
                    H=ConvertCoordinateY(0,\H,#PB_Coordinate_User,#PB_Coordinate_Device)
                    StopVectorDrawing()
                    ResizeGadget(\IdCanvas,#PB_Ignore,#PB_Ignore,W,H)
                Case 1
                    StartVectorDrawing(CanvasVectorOutput(\IdCanvas,#PB_Unit_Millimeter))
                    ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
                    W=ConvertCoordinateX(\W,1,#PB_Coordinate_User,#PB_Coordinate_Device)
                    H=ConvertCoordinateY(0,\H,#PB_Coordinate_User,#PB_Coordinate_Device)
                    StopVectorDrawing()
                    ResizeGadget(\IdCanvas,#PB_Ignore,#PB_Ignore,W,H)
            EndSelect
            Draw()
        EndWith
    EndProcedure
    Procedure GetPxlWidth(IdRull)
        With myRull()
            If ChangeCurrentElement(myRull(),IdRull)=0
                MessageRequester("Rull Error","This Id "+Str(IdRull)+" does not exist")
                ProcedureReturn 
            EndIf
            ProcedureReturn GadgetWidth(\IdCanvas)
        EndWith
    EndProcedure
    Procedure GetPxlHeight(IdRull)
        With myRull()
            If ChangeCurrentElement(myRull(),IdRull)=0
                MessageRequester("Rull Error","This Id "+Str(IdRull)+" does not exist")
                ProcedureReturn 
            EndIf
            ProcedureReturn GadgetHeight(\IdCanvas)
        EndWith
    EndProcedure
    Procedure SetPosition(IdRull,X,Y)
        With myRull()
            If ChangeCurrentElement(myRull(),IdRull)=0
                MessageRequester("Rull Error","This Id "+Str(IdRull)+" does not exist")
                ProcedureReturn 
            EndIf
            ResizeGadget(\IdCanvas,X,Y,#PB_Ignore,#PB_Ignore)
            Draw()
        EndWith
    EndProcedure
    Procedure AddGrid(IdRull,Value,myData,Color.d,size.d)
        With myRull()
             If ChangeCurrentElement(myRull(),IdRull)=0
                MessageRequester("Rull Error","This Id "+Str(IdRull)+" does not exist")
                ProcedureReturn 
            EndIf
            AddElement(\MyGrid())
            \MyGrid()\Value=Value
            \MyGrid()\myData=myData
            \MyGrid()\Color=Color
            \MyGrid()\size=size
            Draw()
            ProcedureReturn @\MyGrid()
        EndWith
    EndProcedure
    Procedure RemoveGrid(IdRull,IdGrid)
        If ChangeCurrentElement(myRull(),IdRull)=0
            MessageRequester("Rull Error","This Id rull "+Str(IdRull)+" does not exist")
            ProcedureReturn #False
        EndIf
        If ChangeCurrentElement(myRull()\MyGrid(),IdGrid)=0
            MessageRequester("Rull Error","This Id grid "+Str(IdGrid)+" does not exist")
            ProcedureReturn #False
        EndIf
        DeleteElement(myRull()\MyGrid())
        myRull()\Hover=#False
        myRull()\IdHover=-1
        ModeMove=#False
        Draw()
        ProcedureReturn #True
    EndProcedure
    Procedure FreeRull(IdRull)
        If ChangeCurrentElement(myRull(),IdRull)=0
            MessageRequester("Rull Error","This Id rull "+Str(IdRull)+" does not exist")
            ProcedureReturn #False
        EndIf
        DeleteElement(myRull())
    EndProcedure
    ;}
EndModule

; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 6
; Folding = 0GA+BQb4---
; Markers = 162,182
; EnableXP