<#
 .Synopsis
  Hudu Powershell Module

 .Description
  Hudu Powershell Module
 .Parameter token
  hudu Api Token for Authentication
 .Example

#>
function hudu_request {
    param(
        $Token,
        $URL,
        $Method,
        $Body

        )

    try {
    
        $WebRequest = [System.Net.WebRequest]::Create($URL)
        $WebRequest.Method = $Method
        $WebRequest.ContentType = "application/json"

        #Get the headers associated with the request.
        $WebHeaderCollection = $WebRequest.Headers


        #Hudu Authentication Header
        $WebHeaderCollection.Add("x-api-key", $Token)

        if ($Body) {

            if ($Body -is [array]) {
                $Body = $Body | ConvertTo-Json
            }

            $RequestStream = $WebRequest.GetRequestStream()
            $RequestStream.Write($Body, 0, $Body.Length)
            $RequestStream.Flush()
            $RequestStream.Close()

        }


        #Get the associated response for the above request.
        $Response = $WebRequest.GetResponse()

        $ResponseStream = $Response.GetResponseStream()

        $ReadStream = New-Object System.IO.StreamReader $ResponseStream

        $Data=$ReadStream.ReadToEnd()

        Return $Data;
    }
    catch {
        Write-Warning $_.Exception.Message
    }

}

function Get-HuduCompanies {
        param(
        $Token,
        $URL,
        $filter_name,
        $filter_number,
        $filter_integration_id ,
        $filter_city,
        $filter_state,
        $filter_website,
        $page,
        $page_size
    )

    $EndPoint = "/api/v1/companies"

    Add-Type -AssemblyName System.Web

    $ParamCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty) 


    if ($filter_city) {
        $ParamCollection.Add('city',$filter_city)
    }
    if ($filter_state) {
        $ParamCollection.Add('state',$filter_state)
    }
    if ($filter_website) {
        $ParamCollection.Add('website',$filter_website)
    }
    if ($page) {
        $ParamCollection.Add('page',$page)
    }
    if ($page_size) {
        $ParamCollection.Add('page_size',$page_size)
    }
    if ($filter_name) {
        $ParamCollection.Add('name',$filter_name)
    }

    if ($filter_number) {
        $ParamCollection.Add('phone_number',$filter_number)
    }
    if ($filter_integration_id) {
        $ParamCollection.Add('id_in_integration',$filter_integration_id)
    }

    Write-Warning $ParamCollection

    $URL = $URL + $EndPoint + "?" + $ParamCollection.ToString()

    write-warning $URL

    $json = hudu_request -Token "$Token" -URL "$URL" -Method "GET"

    $jsonObject = ConvertFrom-Json $json

    return $jsonObject.companies

}
function Get-HuduAssets {
        param(
        $Token,
        $URL,
        $company_id,
        $archived,
        $page,
        $page_size
    )

    $EndPoint = "api/v1/companies/$company_id/assets"

    Add-Type -AssemblyName System.Web

    $ParamCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty) 



    if ($page) {
        $ParamCollection.Add('page',$page)
    }

    if ($archived) {
        $ParamCollection.Add('archived',$archived)
    }
    if ($page_size) {
        $ParamCollection.Add('page_size',$page_size)
    }


    Write-Warning $ParamCollection

    $URL = $URL + $EndPoint + "?" + $ParamCollection.ToString()

    write-warning $URL

    $json = hudu_request -Token "$Token" -URL "$URL" -Method "GET"

    $jsonObject = ConvertFrom-Json $json

    return $jsonObject.assets

}
function Get-HuduCardLookup {
        param(
        $Token,
        $URL,
        $integration_slug,
        $integration_id,
        $integration_identifier,
    )

    $EndPoint = "/api/v1/cards/lookup"

    Add-Type -AssemblyName System.Web

    $ParamCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty) 



    if ($integration_slug) {
        $ParamCollection.Add('integration_slug',$integration_slug)
    }

    if ($integration_id) {
        $ParamCollection.Add('integration_id',$integration_id)
    }
    if ($integration_identifier) {
        $ParamCollection.Add('integration_identifier',$integration_identifier)
    }


    Write-Warning $ParamCollection

    $URL = $URL + $EndPoint + "?" + $ParamCollection.ToString()

    write-warning $URL

    $json = hudu_request -Token "$Token" -URL "$URL" -Method "GET"

    $jsonObject = ConvertFrom-Json $json

    return $jsonObject

}

Export-ModuleMember -Function Get-HuduCompanies
Export-ModuleMember -Function Get-HuduAssets
Export-ModuleMember -Function Get-HuduCardLookup