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
$senzaplatform=""


$Gamesel = $PlayniteApi.MainView.SelectedGames
foreach ($Game in $Gamesel) { 


$gameI = $PlayniteApi.Database.Games[$game.id]


$catName = $game.platforms.name

#$catName = $catName.Split(',')[0] #In caso di giochi con più piattaforme selezionate prende la prima piattaforma (subito prima della virgola).
if($catName -ne $null) {$catName = $catName.Split(',')[0]} #In caso di giochi con più piattaforme selezionate prende la prima piattaforma (subito prima della virgola). #new




$nomibrevi = @{}

	Get-Content -Path "$PSScriptRoot\Platforms.txt" | ForEach-Object {
	$parts = $_ -split "="
    $platform = $parts[0].Trim()
    $names = $parts[1].Trim() -split ";"
    $nomibrevi[$platform] = $names
}



#$catNameS=$nomibrevi[$catname]
if($catName -ne $null) {$catNameS=$nomibrevi[$catname]}





if (!$game.source.name) {  # Se la sorgente è vuota
    if ($catName -ne $null) {  # Se la piattaforma del gioco non è vuota
        if ($nomibrevi.ContainsKey($catName)) { #Se la categoria esiste già aggiunge il gioco alla categoria, altrimenti crea una nuova categoria col nome della piattaforma.
            $nomibrevi[$catName] | ForEach-Object {
                $category = $PlayniteApi.Database.Categories.Add($_)
                if ($gameI.CategoryIds -eq $null -or !$gameI.CategoryIds.Contains($category.Id)) {
                    $gameI.CategoryIds += $category.Id
                }
                $PlayniteApi.Database.Games.Update($gameI)
                $arrgame += $game.name
                $arrcat += $category.name
            }
        } else {
            $category = $PlayniteApi.Database.Categories.Add($catName)
            if ($gameI.CategoryIds -eq $null -or !$gameI.CategoryIds.Contains($category.Id)) {
                $gameI.CategoryIds += $category.Id
            }
            $PlayniteApi.Database.Games.Update($gameI)
            $arrgame += $game.name
            $arrcat += $category.name
        }
    } else {
        $arrgame += $game.name
        $arrcat += "SENZA PIATTAFORMA"
    }
} else {  # Se c'è una sorgente
    $sou = $game.source.name
    $sorgente = @{}
    Get-Content -Path "$PSScriptRoot\Source.txt" | ForEach-Object {
        $parts = $_ -split "="
        $sorgente[$parts[0].Trim()] = $parts[1].Trim()
    }

    if ($sorgente.ContainsKey($sou)) {
        $category = $PlayniteApi.Database.Categories.Add($sorgente[$sou])
    } else {
        $category = $PlayniteApi.Database.Categories.Add($sou)
    }

    if ($gameI.CategoryIds -eq $null -or !$gameI.CategoryIds.Contains($category.Id)) {
        $gameI.CategoryIds += $category.Id
    }
    $PlayniteApi.Database.Games.Update($gameI)
    $arrgame += $game.name
    $arrcat += $category.name
}
#else (sorgente)
	

	

##$arrgame+=$game.name    #!!!
##$arrcat+=$category.name






}#foreach game




<#
foreach ($categoria in $arrcat) {
	#$PlayniteApi.Dialogs.ShowMessage("3")
  
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

#>

# Creazione di un array associato per evitare duplicazioni
foreach ($categoria in $arrcat) {
    $giochi = @()
    for ($i = 0; $i -lt $arrgame.Count; $i++) {
        if ($arrcat[$i] -eq $categoria) {
            $giochi += $arrgame[$i]
        }
    }
    $arr[$categoria] = $giochi
}

# Creazione del messaggio di output
$output = ""
foreach ($categoria in $arr.Keys) {
    $output += "$categoria" + ": "
    $output += '"' + $($arr[$categoria] -join '", "') + '"' + "`n`n"
}

# Visualizza il risultato finale
$PlayniteApi.Dialogs.ShowMessage($output)






} #end func
