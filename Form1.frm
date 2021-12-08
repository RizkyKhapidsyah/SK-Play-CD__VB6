VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "mciSendString CD Player"
   ClientHeight    =   1290
   ClientLeft      =   150
   ClientTop       =   435
   ClientWidth     =   4800
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1290
   ScaleWidth      =   4800
   StartUpPosition =   2  'CenterScreen
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   4080
      Top             =   840
   End
   Begin VB.CommandButton eject 
      Caption         =   "ejc"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   4200
      TabIndex        =   8
      Top             =   360
      Width           =   495
   End
   Begin VB.CommandButton ff 
      Caption         =   ">>"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3720
      TabIndex        =   7
      Top             =   360
      Width           =   495
   End
   Begin VB.CommandButton rew 
      Caption         =   "<<"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3240
      TabIndex        =   6
      Top             =   360
      Width           =   495
   End
   Begin VB.CommandButton ftrack 
      Caption         =   ">>|"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2760
      TabIndex        =   5
      Top             =   360
      Width           =   495
   End
   Begin VB.CommandButton btrack 
      Caption         =   "|<<"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2280
      TabIndex        =   4
      Top             =   360
      Width           =   495
   End
   Begin VB.CommandButton stopbtn 
      Caption         =   "x"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   4200
      TabIndex        =   3
      Top             =   0
      Width           =   495
   End
   Begin VB.CommandButton pause 
      Caption         =   "||"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3720
      TabIndex        =   2
      Top             =   0
      Width           =   495
   End
   Begin VB.CommandButton play 
      Caption         =   ">"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2280
      TabIndex        =   1
      Top             =   0
      Width           =   1455
   End
   Begin VB.TextBox timeWindow 
      Alignment       =   2  'Center
      BackColor       =   &H80000008&
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000000&
      Height          =   735
      Left            =   120
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   0
      Width           =   2055
   End
   Begin VB.Label tracktime 
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Left            =   2880
      TabIndex        =   10
      Top             =   960
      Width           =   1815
   End
   Begin VB.Label totalplay 
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   960
      Width           =   2655
   End
   Begin VB.Menu options 
      Caption         =   "Options"
      Begin VB.Menu ffspeed 
         Caption         =   "Fast forward speed"
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim fastForwardSpeed As Long    ' seconds to seek for ff/rew
Dim fPlaying As Boolean         ' true if CD is currently playing
Dim fCDLoaded As Boolean        ' true if CD is the the player
Dim numTracks As Integer        ' number of tracks on audio CD
Dim trackLength() As String     ' array containing length of each track
Dim track As Integer            ' current track
Dim min As Integer              ' current minute on track
Dim sec As Integer              ' current second on track
Dim cmd As String               ' string to hold mci command strings

' Send a MCI command string
' If fShowError is true, display a message box on error
Private Function SendMCIString(cmd As String, fShowError As Boolean) As Boolean
Static rc As Long
Static errStr As String * 200

rc = mciSendString(cmd, 0, 0, hWnd)
If (fShowError And rc <> 0) Then
    mciGetErrorString rc, errStr, Len(errStr)
    MsgBox errStr
End If
SendMCIString = (rc = 0)
End Function

Private Sub Form_Load()

' If we're already running, then quit
If (App.PrevInstance = True) Then
    End
End If

' Initialize variables
Timer1.Enabled = False
fastForwardSpeed = 5
fCDLoaded = False

' If the cd is being used, then quit
If (SendMCIString("open cdaudio alias cd wait shareable", True) = False) Then
    End
End If

SendMCIString "set cd time format tmsf wait", True
Timer1.Enabled = True

End Sub

Private Sub Form_Unload(Cancel As Integer)
'Close all MCI devices opened by this program
SendMCIString "close all", False
End Sub

' Play the CD
Private Sub play_Click()
SendMCIString "play cd", True
fPlaying = True
End Sub
' Stop the CD play
Private Sub stopbtn_Click()
SendMCIString "stop cd wait", True
cmd = "seek cd to " & track
SendMCIString cmd, True
fPlaying = False
Update
End Sub
' Pause the CD
Private Sub pause_Click()
SendMCIString "pause cd", True
fPlaying = False
Update
End Sub
' Eject the CD
Private Sub eject_Click()
SendMCIString "set cd door open", True
Update
End Sub
' Fast forward
Private Sub ff_Click()
Dim s As String * 40

SendMCIString "set cd time format milliseconds", True
mciSendString "status cd position wait", s, Len(s), 0
If (fPlaying) Then
    cmd = "play cd from " & CStr(CLng(s) + fastForwardSpeed * 1000)
Else
    cmd = "seek cd to " & CStr(CLng(s) + fastForwardSpeed * 1000)
End If
mciSendString cmd, 0, 0, 0
SendMCIString "set cd time format tmsf", True
Update
End Sub
' Rewind the CD
Private Sub rew_Click()
Dim s As String * 40

SendMCIString "set cd time format milliseconds", True
mciSendString "status cd position wait", s, Len(s), 0
If (fPlaying) Then
    cmd = "play cd from " & CStr(CLng(s) - fastForwardSpeed * 1000)
Else
    cmd = "seek cd to " & CStr(CLng(s) - fastForwardSpeed * 1000)
End If
mciSendString cmd, 0, 0, 0
SendMCIString "set cd time format tmsf", True
Update
End Sub
' Forward track
Private Sub ftrack_Click()
If (track < numTracks) Then
    If (fPlaying) Then
        cmd = "play cd from " & track + 1
        SendMCIString cmd, True
    Else
        cmd = "seek cd to " & track + 1
        SendMCIString cmd, True
    End If
Else
    SendMCIString "seek cd to 1", True
End If
Update
End Sub
' Go to previous track
Private Sub btrack_Click()
Dim from As String
If (min = 0 And sec = 0) Then
    If (track > 1) Then
        from = CStr(track - 1)
    Else
        from = CStr(numTracks)
    End If
Else
    from = CStr(track)
End If
If (fPlaying) Then
    cmd = "play cd from " & from
    SendMCIString cmd, True
Else
    cmd = "seek cd to " & from
    SendMCIString cmd, True
End If
Update
End Sub
' Update the display and state variables
Private Sub Update()
Static s As String * 30

' Check if CD is in the player
mciSendString "status cd media present", s, Len(s), 0
If (CBool(s)) Then
    ' Enable all the controls, get CD information
    If (fCDLoaded = False) Then
        mciSendString "status cd number of tracks wait", s, Len(s), 0
        numTracks = CInt(Mid$(s, 1, 2))
        eject.Enabled = True
        
        ' If CD only has 1 track, then it's probably a data CD
        If (numTracks = 1) Then
            Exit Sub
        End If
        
        mciSendString "status cd length wait", s, Len(s), 0
        totalplay.Caption = "Tracks: " & numTracks & "  Total time: " & s
        ReDim trackLength(1 To numTracks)
        Dim i As Integer
        For i = 1 To numTracks
            cmd = "status cd length track " & i
            mciSendString cmd, s, Len(s), 0
            trackLength(i) = s
        Next
        play.Enabled = True
        pause.Enabled = True
        ff.Enabled = True
        rew.Enabled = True
        ftrack.Enabled = True
        btrack.Enabled = True
        stopbtn.Enabled = True
        fCDLoaded = True
        SendMCIString "seek cd to 1", True
    End If

    ' Update the track time display
    mciSendString "status cd position", s, Len(s), 0
    track = CInt(Mid$(s, 1, 2))
    min = CInt(Mid$(s, 4, 2))
    sec = CInt(Mid$(s, 7, 2))
    timeWindow.Text = "[" & Format(track, "00") & "] " & Format(min, "00") _
            & ":" & Format(sec, "00")
    tracktime.Caption = "Track time: " & trackLength(track)
    
    ' Check if CD is playing
    mciSendString "status cd mode", s, Len(s), 0
    fPlaying = (Mid$(s, 1, 7) = "playing")
Else
    eject.Enabled = False
    ' Disable all the controls, clear the display
    If (fCDLoaded = True) Then
        play.Enabled = False
        pause.Enabled = False
        ff.Enabled = False
        rew.Enabled = False
        ftrack.Enabled = False
        btrack.Enabled = False
        stopbtn.Enabled = False
        fCDLoaded = False
        fPlaying = False
        totalplay.Caption = ""
        tracktime.Caption = ""
        timeWindow.Text = ""
    End If
End If
End Sub
' Set the fast-forward speed
Private Sub ffspeed_Click()
Dim s As String
s = InputBox("Enter the new speed in seconds", "Fast Forward Speed", CStr(fastForwardSpeed))
If IsNumeric(s) Then
    fastForwardSpeed = CLng(s)
End If
End Sub

Private Sub Timer1_Timer()
Update
End Sub

