;************************************************************************************************************************
; Author : MicrodevWeb
; Project Name : PbPrint
; File Name : Rull.pbi
; Module : Rull
; Description : 
; Version : B0.1
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
    ;}
EndDeclareModule
Module Rull
    EnableExplicit
    ;-* LOCAL VARIABLE/LIST/MAP/CONSTANTE
    Structure Rull
        IdCanvas.i
        W.d
        H.d
        Direction.i
        ZoomFactor.d
        Value.d
        *CallBack
        Hover.b
    EndStructure
    Global NewList myRull.Rull()
    #BgColor=$FFDEDEDE
    #FgColor=$FF242424
    Global UnitFont=LoadFont(#PB_Any,"Arial",6,#PB_Font_HighQuality)
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
        If myRull()\Hover
            DrawIndexValueH()
        EndIf
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
            Static  MX,MY,ModeMove.b,ClicOn.b=#False
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
                                \Value=MX
                                Draw()
                                SendCallback(#False)
                                ProcedureReturn 
                            EndIf
                            If MX=\Value
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
                                \Value=MY
                                Draw()
                                SendCallback(#False)
                                ProcedureReturn 
                            EndIf
                            If ModeMove And Not ClicOn
                                SendCallback(#True)
                            EndIf
                            If MY=\Value
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
        With myRull()
            CallFunctionFast(\CallBack,ListIndex(myRull()),\Value,LeftUp)
        EndWith
    EndProcedure
    Procedure DrawUnitV()
        DrawTxtUnitV()
        DrawLineUniV()
        If myRull()\Hover
            DrawIndexValueV()
        EndIf
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
            ProcedureReturn ListIndex(myRull())
        EndWith
    EndProcedure
    Procedure SetZoom(IdRull,ZoomFactor.d=1)
        With myRull()
            Protected W,H
            If SelectElement(myRull(),IdRull)=0
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
            If SelectElement(myRull(),IdRull)=0
                MessageRequester("Rull Error","This Id "+Str(IdRull)+" does not exist")
                ProcedureReturn 
            EndIf
            ProcedureReturn GadgetWidth(\IdCanvas)
        EndWith
    EndProcedure
    Procedure GetPxlHeight(IdRull)
        With myRull()
            If SelectElement(myRull(),IdRull)=0
                MessageRequester("Rull Error","This Id "+Str(IdRull)+" does not exist")
                ProcedureReturn 
            EndIf
            ProcedureReturn GadgetHeight(\IdCanvas)
        EndWith
    EndProcedure
    Procedure SetPosition(IdRull,X,Y)
        With myRull()
            If SelectElement(myRull(),IdRull)=0
                MessageRequester("Rull Error","This Id "+Str(IdRull)+" does not exist")
                ProcedureReturn 
            EndIf
            ResizeGadget(\IdCanvas,X,Y,#PB_Ignore,#PB_Ignore)
            Draw()
        EndWith
    EndProcedure
    ;}
EndModule




; IDE Options = PureBasic 5.50 beta 1 (Windows - x64)
; CursorPosition = 381
; FirstLine = 358
; Folding = --------
; EnableXP