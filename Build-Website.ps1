<#
Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
#>

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
