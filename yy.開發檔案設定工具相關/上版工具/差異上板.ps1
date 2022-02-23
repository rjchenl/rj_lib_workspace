param(
    
    [String] $NewTag = "p.0.0.0.20211230142400",
    [String] $OldTag = "p.0.0.0.20211229173000",
    [String] $gitFolderPath = "D:/DEV/CIFX_GIT/cifx/"
)

function isEmpty( $inputt ) {
  if (!$inputt){
  Write-ERROR "empty"
  pause
  exit 2
  }
}



function genFile($modifiedFiles, $pathO) {
    if ($modifiedFiles) {
		    foreach ($modifiedFileOne in $modifiedFiles){
                $targetFileName = Split-Path $modifiedFileOne -Leaf
                Copy-Item -Path $modifiedFileOne -Destination ./$pathO/$targetFileName -Force
            }
    }
  
}

    
function tagValidation( $newTag , $oldTag ) {

    if([datetime]::ParseExact($NewTag.Substring($NewTag.LastIndexOf(".")+1,12), "yyyyMMddHHmm", $null) -gt [datetime]::ParseExact($oldTag.Substring($oldTag.LastIndexOf(".")+1,12), "yyyyMMddHHmm", $null)) {
    Write-Host tag time is validate
    } else {
    Write-ERROR tag time is  NOT validate
    pause
    exit 2
    }


}




#$NewTag = Read-Host '請輸入本次 new Tag'
#$OldTag = Read-Host '請輸入上次 old Tag'


#空值驗證
isEmpty $NewTag
isEmpty $OldTag


#日期驗證
#tagValidation $NewTag $OldTag

Set-Location $gitFolderPath
git fetch
git checkout -f $NewTag
$pathO = "Deploy/CIFX"



if (Test-Path Deploy) { Remove-Item -Recurse -Force Deploy}
if (Test-Path Rollback) { Remove-Item -Recurse -Force Rollback}
if (Test-Path Assigment) { Remove-Item -Recurse -Force Assigment}


New-Item -ItemType directory -Path "$gitFolderPath/$pathO" -Force

$modifiedFilesFunction = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/function
genFile $modifiedFilesFunction $pathO

$modifiedFilesPackage = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/package
genFile $modifiedFilesPackage $pathO


$modifiedFilesProcedure = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/procedure
genFile $modifiedFilesProcedure $pathO

$pathO = "Deploy/CIFX/DDL_DML"
if (Test-Path $gitFolderPath/$pathO) { Remove-Item -Recurse -Force $gitFolderPath/$pathO}
New-Item -ItemType directory -Path "$gitFolderPath/$pathO" -Force


$modifiedFilesDdl = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/ddl
genFile $modifiedFilesDdl $pathO
$modifiedFilesDml = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/dml
genFile $modifiedFilesDml $pathO


git checkout -f $OldTag
$pathO = "Rollback/CIFX"
if (Test-Path $gitFolderPath/$pathO) { Remove-Item -Recurse -Force $gitFolderPath/$pathO}
#Remove-Item -Recurse -Force "$gitFolderPath/$pathO"
New-Item -ItemType directory -Path "$gitFolderPath/$pathO" -Force

genFile $modifiedFilesFunction $pathO
genFile $modifiedFilesPackage $pathO
genFile $modifiedFilesProcedure $pathO


# Batch

Set-Location $gitFolderPath

git checkout -f $NewTag

$pathO = "Deploy/CIFX_BATCH"

New-Item -ItemType directory -Path "$gitFolderPath/$pathO" -Force

$modifiedFilesFunction = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/batch/function
genFile $modifiedFilesFunction $pathO


$modifiedFilesPackage = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/batch/package
genFile $modifiedFilesPackage $pathO


$modifiedFilesProcedure = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/batch/procedure

genFile $modifiedFilesProcedure $pathO

$pathO = "Deploy/CIFX_BATCH/DDL_DML"
if (Test-Path $gitFolderPath/$pathO) { Remove-Item -Recurse -Force $gitFolderPath/$pathO}
New-Item -ItemType directory -Path "$gitFolderPath/$pathO" -Force


$modifiedFilesDdl = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/batch/ddl
genFile $modifiedFilesDdl $pathO
$modifiedFilesDml = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT -- cifx-db-procedure/batch/dml
genFile $modifiedFilesDml $pathO


git checkout -f $OldTag
$pathO = "Rollback/CIFX_BATCH"
New-Item -ItemType directory -Path "$gitFolderPath/$pathO" -Force

genFile $modifiedFilesFunction $pathO
genFile $modifiedFilesPackage $pathO
genFile $modifiedFilesProcedure $pathO





git checkout -f $NewTag

$changeObjectList = git diff --name-only "$OldTag..$NewTag" --diff-filter=ACMRT

$results = @()

ForEach($singleChangeObject in $changeObjectList){


$schangeObject = git config --global i18n.logoutputencoding big5 | git log -n 1 --pretty=format:"%an @%ad @%s" $singleChangeObject

$changeObjectArray = $schangeObject.Split("@")



$details = @{            
            
                Date     = $changeObjectArray[1]         
                Author      = $changeObjectArray[0]
                Subject     =  $changeObjectArray[2]
                changeObject = $singleChangeObject
        }  
        
$results += New-Object PSObject -Property $details     


}


$outputCsvPoisition = [string](Get-Location) 
$outputCsvPoisition = $outputCsvPoisition + "\data.csv"

#clear last output csv file
if (Test-Path $outputCsvPoisition) { Remove-Item -Recurse -Force $outputCsvPoisition}

$results | export-csv -Path $outputCsvPoisition -NoTypeInformation -Encoding UTF8




#====== 產生merged master branch list START ========

git checkout -f $NewTag


#產生tmp master
git checkout -b tmp_master origin/master

$mergedMasterList = git log --pretty=format:"%s" | select-string -Pattern '^(Merge branch).*(into ).*(master)'

$tmpMergedMasterList = @()

forEach($singleOneBranch in $mergedMasterList){
   
   [String]$singleOneBranch = $singleOneBranch

    $singleOneBranch = $singleOneBranch.Substring($singleOneBranch.IndexOf("'")+1,$singleOneBranch.IndexOf("'",$singleOneBranch.IndexOf("'")+1)-$singleOneBranch.IndexOf("'")-1)
    
    $tmpMergedMasterList  += New-Object PSObject  $singleOneBranch       
}

$outputBranchList = $tmpMergedMasterList | Select-Object @{Name='mergedMasterBranch';Expression={$_}}
$outputCsvPoisitionForMergedMaster = [string](Get-Location) 
$outputCsvPoisitionForMergedMaster = $outputCsvPoisitionForMergedMaster + "\mergedMasterList.csv"


#刪除前次檔案
if (Test-Path $outputCsvPoisitionForMergedMaster) { Remove-Item -Recurse -Force $outputCsvPoisitionForMergedMaster}
$outputBranchList | Export-Csv -Path $outputCsvPoisitionForMergedMaster -NoTypeInformation -Encoding UTF8

#co 至其它br
git checkout -f $NewTag

#刪除tmp master
git branch -D tmp_master

#====== 產生merged master branch list END ========





Write-Host  "=============== 執行完成 ================"

pause


