$pages = Get-ChildItem -Path $PSScriptRoot/pages -File
$pandocArgs = @(
    '--from',
    'markdown-auto_identifiers',
    '--standalone',
    '--template=templates/default.html'
)
$partialPath = "$PSScriptRoot/templates/list.html"
$posts = Get-ChildItem -Path $PSScriptRoot/posts | Sort-Object -Property Name -Descending

Get-ChildItem -Path $PSScriptRoot/docs -File -ErrorAction Ignore | Remove-Item
Get-ChildItem -Path $partialPath -ErrorAction Ignore | Remove-Item

Add-Content -Path $partialPath -Value '<ul>'

$posts.ForEach{
    $title = Select-String -InputObject $_ -Pattern '^title: "(.*?)"$'
    $listItem = "<li><a href='/$($_.BaseName).html'>$($title.Matches.groups[1].value)</a></li>"
    Add-Content -Path $partialPath -Value $listItem
    pandoc.exe $_.FullName $pandocArgs --output=$PSScriptRoot/docs/$($_.BaseName).html
}

Add-Content -Path $partialPath -Value '</ul>' -NoNewline

# (Windows PowerShell workaround) Force BOM-less UTF-8 encoding
[IO.File]::WriteAllLines((Get-Item -Path $partialPath).FullName, (Get-Content -Raw $partialPath))

$pages.ForEach{
    if ($_.Name -eq 'index.md') {
        pandoc.exe $_.FullName --variable=index:true $pandocArgs --output=$PSScriptRoot/docs/$($_.BaseName).html
    } else {
        pandoc.exe $_.FullName $pandocArgs --output=$PSScriptRoot/docs/$($_.BaseName).html
    }
}

Copy-Item -Path $PSScriptRoot/static/* -Destination $PSScriptRoot/docs
