function editCode([string]$type="",[string]$file=""){
    $guiEdit="${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
    $cmdEdit="$env:USERPROFILE\Documents\Programming\nvim-win64\Neovim\bin\nvim.exe"

    #Write-Host $guiEdit
    #Write-Host $cmdEdit

    if (Test-Path -Path $file){
        if ($type.ToUpper() -eq "GUI"){
            if ($file -ne ""){
                & $guiEdit $file
            } else {
                & $guiEdit
            }
        } elseif ($type.ToUpper() -eq "CMD"){
            if ($file -ne ""){
                & $cmdEdit $cmdEditConfig $file
            } else {
                & $cmdEdit $cmdEditConfig
            }
        } else {
            Write-Host 
            Write-Host "!> Invalid type parameter: '"$type"'"
            Write-Host " >Possible type parameters are:"
            Write-Host "  . GUI: To launch a gui text editor"
            Write-Host "  . CMD: To launch a cmd text editor"
        }
    } else {
        Write-Host "!> Given file does not exist."
    }
}

function runCode([string]$operationType="",[string]$file=""){
	$originalDir=Get-Location
    $buildAndRunPath="$env:USERPROFILE\Documents\Programming\C Programms\BuildAndRun\Version1"
    $buildAndRunAbsPath="$env:USERPROFILE\Documents\Programming\C Programms\BuildAndRun\Version1\BuildAndRun.exe"
    
    # Write-Host "File "$file
	# Write-Host "Origdir: " $originalDir
	
    if (Test-Path -path $file){
		Set-Location $buildAndRunPath	#TODO - Get rid of this shit and make build and run a full application.
		& $buildAndRunAbsPath $operationType $file
		Set-Location $originalDir
    } else {
        Write-Host
        Write-Host "!> Given file does not exist."
    }
}

function viewPicture([string]$file){
	[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
	[System.Windows.Forms.Application]::EnableVisualStyles();
	function changeImage([string]$direction){
		If ($direction -Match "next"){
			$FileIndex+=1
		} ElseIf ($direction -Match "previous"){
			$FileIndex-=1
		}
		IF ($FileIndex -ge $allFiles.Count){
			$FileIndex=0
		} ElseIf ($FileIndex -lt 0){
			$FileIndex=$allFiles.Count-1
		}
		$img=[System.Drawing.Image]::FromFile($allFiles[$fileIndex])
		$picture.Image=$img
		$currentFile=$allFiles[$FileIndex]
		$FileName.Text="Showing Image: $currentFile"
		$information.Text="Image $FileIndex/$totalFiles | N:next  P:previous  Q:quit"
	}

	$absFile=(Get-Item $file)
	$directory=(Split-Path $absFile)
	$allFiles=(Get-ChildItem -Path "$directory\*" -Include "*.jpg","*.JPG","*.jpeg","*.JPEG","*.png","*.PNG")
	$totalFiles=$allFiles.Count-1
	Set-Variable -Name currentFile -Option AllScope -Value $absFile
	Set-Variable -Name FileIndex -Option AllScope -Value 0
	if ($allFiles.Length -gt 0){
		$FileName=New-Object System.Windows.Forms.Label
		$FileName.ForeColor=[System.Drawing.Color]::White
		$FileName.BackColor=[System.Drawing.Color]::Black
		$FileName.Anchor="Left"
		$FileName.AutoSize=$True
		
		$information=New-Object System.Windows.Forms.Label
		$information.ForeColor=[System.Drawing.Color]::White
		$information.BackColor=[System.Drawing.Color]::Black
		$information.Anchor="Right"
		$information.AutoSize=$True
		$information.Text=""	#this will be updated when changeImage() is called

		#$NextButton=New-Object System.Windows.Forms.Button
		#$NextButton.Anchor="Left"
		#$NextButton.Top=$FileName.Top+$FileName.Height
		#$NextButton.Left=$FileName.Left
		#$NextButton.Text="Next(&n)"
		#$NextButton.Add_Click({
		#	changeImage("next")
		#})

		#$PreviousButton=New-Object System.Windows.Forms.Button
		#$PreviousButton.Anchor="Left"
		#$PreviousButton.Top=$FileName.Top+$FileName.Height
		#$PreviousButton.Left=$FileName.Left+$NextButton.Width
		#$PreviousButton.Text="Previous(&p)"
		#$PreviousButton.Add_Click({
		#	changeImage("previous")
		#})

		#$CancelButton=New-Object System.Windows.Forms.Button
		#$CancelButton.Anchor="Left"
		#$CancelButton.Top=$FileName.Top+$FileName.Height
		#$CancelButton.Left=$FileName.Left+$NextButton.Width+$PreviousButton.Width
		#$CancelButton.Text="Cancel(&q)"
		#$CancelButton.DialogResult=[System.Windows.Forms.DialogResult]::Cancel

		$Panel=New-Object Windows.Forms.Panel
		$Panel.Dock="Bottom"
		$Panel.Controls.Add($FileName)
		$Panel.Controls.Add($information)

		$picture=New-Object Windows.Forms.PictureBox
		$picture.Dock=[System.Windows.Forms.DockStyle]::Fill
		$picture.SizeMode=[System.Windows.Forms.PictureBoxSizeMode]::Zoom
		$FileIndex=-1
		changeImage("next")

		$form=New-Object Windows.Forms.Form
		$form.Text="Image Viewer"
		$form.BackColor="Black"
		$form.AutoScroll=$True
		#$form.CancelButton=$CancelButton
		$form.MinimizeBox=$False
		$form.MaximizeBox=$False
		$form.WindowState="Maximized"
		$form.Add_KeyDown({
			if ($_.keyCode -eq "N"){
				changeImage("next")
			}
		})
		$form.Add_KeyDown({
			if ($_.keyCode -eq "P"){
				changeImage("previous")
			}
		})
		$form.Add_KeyDown({
			if ($_.KeyCode -eq "Q" -or $_.KeyCode -eq "Escape"){
				$form.Close()
			}
		})
		$form.Controls.Add($Panel)
		$form.controls.Add($picture)
		$form.Add_Shown({
			$form.Activate
		})
		$form.KeyPreview=$True
		$form.ShowDialog()
	 } Else {
		 Write-Host "The current directory does not have any image files."
	 }

}

Set-Alias -Name Edit-Code -Value editCode
Set-Alias -Name Run-Code -value runCode
Set-Alias -Name View-Picture -Value viewPicture
