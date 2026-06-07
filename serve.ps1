$port = 8080
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Listening on http://localhost:$port/"
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $response = $context.Response
        $requestPath = $context.Request.Url.LocalPath.TrimStart('/')
        if ($requestPath -eq "") { $requestPath = "index.html" }
        $fullPath = Join-Path (Get-Location) $requestPath
        
        if (Test-Path $fullPath) {
            $content = [System.IO.File]::ReadAllBytes($fullPath)
            
            $ext = [System.IO.Path]::GetExtension($fullPath)
            switch ($ext) {
                ".html" { $response.ContentType = "text/html" }
                ".jpg"  { $response.ContentType = "image/jpeg" }
                ".js"   { $response.ContentType = "application/javascript" }
                ".css"  { $response.ContentType = "text/css" }
            }
            
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
