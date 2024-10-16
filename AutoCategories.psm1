function GetGameMenuItems
{
    param(
		$getGameMenuItemsArgs
	)

    $menuItem = New-Object Playnite.SDK.Plugins.ScriptGameMenuItem
    $menuItem.Description = "AutoCategories"
    $menuItem.FunctionName = "vai"
	$menuItem.Icon = "$PSScriptRoot"+"\icon.jpg"
	
    return $menuItem
}

function GetMainMenuItems
{
    param(
		
		$getMainMenuItemsArgs
	)

    $menuItem = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
    $menuItem.Description = "AutoCategories"
    $menuItem.FunctionName = "vai"
	$menuItem.Icon = "$PSScriptRoot"+"\icon.jpg"
	#$menuItem.MenuSection = "@AutoCategories"
	
    return $menuItem
}


function vai
{
	param(
		$getGameMenuItemsArgs
	)

$arrgame=@()
$arrcat=@()
$arr=@{}


$Gamesel = $PlayniteApi.MainView.SelectedGames
foreach ($Game in $Gamesel) { 


$gameI = $PlayniteApi.Database.Games[$game.id]


$catName = $game.platforms.name
$catName = $catName.Split(',')[0] #In caso di giochi con più piattaforme selezionate prende la prima piattaforma (subito prima della virgola).



$nomibrevi = @{}

	Get-Content -Path "$PSScriptRoot\Platforms.txt" | ForEach-Object {
	$parts = $_ -split "="
    $nomibrevi[$parts[0].Trim()] = $parts[1].Trim()
}



$catNameS=$nomibrevi[$catname]





if (!$game.source.name){ #Se la sorgente è vuota

if($nomibrevi.Containskey($catName)){ #Se la categoria esiste già aggiunge il gioco alla categoria, altrimenti crea una nuova categoria col nome della piattaforma.
	


$category = $PlayniteApi.Database.Categories.Add($catNameS)



}else{

$category = $PlayniteApi.Database.Categories.Add($catName)

}



if ($gameI.CategoryIds -ne $null) {
if ($gameI.CategoryIds.Contains($category.Id)) {
   
} else {
   
 
   $gameI.CategoryIds += $category.Id



}

} else{ #Categoria nulla:
	 
	
	$gameI.CategoryIds=$null # "Svuota" cosa in realtà non era stato eliminato.
	$gameI.CategoryIds += $category.Id
	


}


$PlayniteApi.Database.Games.Update($gameI)



}#endif source empty check
else{ #Se c'è la sorgente:

	$sou=$game.source.name  
	
	$sorgente = @{}

	Get-Content -Path "$PSScriptRoot\Source.txt" | ForEach-Object {
	$parts = $_ -split "="
    $sorgente[$parts[0].Trim()] = $parts[1].Trim()
}
	
	
	$souS=$sorgente[$sou]
	
	if($sorgente.Containskey($sou)){ #Se la categoria esiste già aggiunge il gioco alla categoria, altrimenti crea una nuova categoria col nome della sorgente.
		$category = $PlayniteApi.Database.Categories.Add($souS)
	}else{
		$category = $PlayniteApi.Database.Categories.Add($sou)
		#$category = $PlayniteApi.Database.Categories.Add($game.source)
}
if ($gameI.CategoryIds -ne $null) {
if ($gameI.CategoryIds.Contains($category.Id)) {
    
} else {
   
   $gameI.CategoryIds += $category.Id
}

} else{ #Categoria nulla:

	$gameI.CategoryIds=$null # "Svuota" cosa in realtà non era stato eliminato.
	$gameI.CategoryIds += $category.Id
}
		$PlayniteApi.Database.Games.Update($gameI)
		

}#else (sorgente)
	

	

$arrgame+=$game.name
$arrcat+=$category.name




}#foreach game





foreach ($categoria in $arrcat) {
  
    $giochi = @()

    
    for ($i = 0; $i -lt $arrgame.Count; $i++) {
        
        if ($arrcat[$i] -eq $categoria) {
            
            $giochi += $arrgame[$i]
        }
    }

    
    $arr[$categoria] = $giochi
}


$output = ""
foreach ($categoria in $arr.Keys) {
    $output += "$categoria"+": "
	$output += '"'+ $($arr[$categoria] -join '", "') +'"' + "`n`n"

	
}



$PlayniteApi.Dialogs.ShowMessage($output)
} #end func