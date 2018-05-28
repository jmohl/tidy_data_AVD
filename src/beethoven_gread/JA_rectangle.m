function JA_rectangle(X,WinX, Y, WinY,FaceColor)

line([X-WinX/2 X+WinX/2],[Y+WinY/2 Y+WinY/2],'color',FaceColor,'linewidth',0.8)
line([X-WinX/2 X+WinX/2],[Y-WinY/2 Y-WinY/2],'color',FaceColor,'linewidth',0.8)
line([X-WinX/2 X-WinX/2],[Y-WinY/2 Y+WinY/2],'color',FaceColor,'linewidth',0.8)
line([X+WinX/2 X+WinX/2],[Y-WinY/2 Y+WinY/2],'color',FaceColor,'linewidth',0.8)

