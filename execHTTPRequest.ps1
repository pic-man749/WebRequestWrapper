class execHTTPRequest{

    $responseHeader
    $responseBody
    $statusCode
    [string]$proxy_url = "*****"
    $METHODS = @('GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'CONNECT', 'OPTIONS', 'TRACE')

    execHTTPRequest(){
        $this.resetResponse()
    }

    [bool] execute([string]$url, [string]$method, [Hashtable]$header, $body, [bool]$isProxySet){

        # Do NOT set Body those methods, maybe
        # ref)https://www.rfc-editor.org/rfc/rfc7231
        # BUT Invoke-Rest/webMethod command uses Body parameter even with GET
        # https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.3

        $this.resetResponse()

        # unkown method
        if(!$this.METHODS.Contains($method)){
            return $false
        }
        
        try{
            if($isProxySet){
                $response = Invoke-WebRequest $url -Method $method -Headers $header -Body $body -Proxy $this.proxy_url
            }else{
                $response = Invoke-WebRequest $url -Method $method -Headers $header -Body $body
            }
            $this.statusCode = $response.StatusCode
            $this.responseHeader = $response.Headers
            $this.responseBody = $response.Content
    
            return $true
        }catch{
            # Write-host $_
            return $false
        }
    }

    [void] setProxy([string]$proxy){
        $this.proxy_url = $proxy
    }

    [bool] isValidJson([string]$str){
        # v5 and earlier version cannot use Test-Json 
        [bool]$isValid = $false
        try{
            $dummy = ConvertFrom-Json $str -ErrorAction Stop;
            $isValid = $true
        }catch{
            $isValid = $false
        }
        return $isValid
    }

    [string] formatJson([string]$str){
        if($this.isValidJson($str)){
            return ConvertFrom-Json $str | ConvertTo-Json -Depth 100 # max:100
        }
        return $str    
    }

    [void] resetResponse(){
        $this.statusCode = $null
        $this.responseHeader = $null
        $this.responseBody = $null
    }
}