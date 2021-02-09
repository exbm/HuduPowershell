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

            $RequestStream = $WebRequest.GetRequestStream()


            $BodyBytes = [byte[]][char[]] $Body

            $RequestStream.Write($BodyBytes, 0, $BodyBytes.Length)

            $RequestStream.flush()
            #$ReadStream = New-Object System.IO.StreamReader $RequestStream

            #$Data=$ReadStream.ReadToEnd()
            #Write-Warning $Data

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
function Get-AssetLookup {
        param(
        $Token,
        $URL,
        $primary_serial,
    )

    $EndPoint = "api/v1/asset_lookup"

    Add-Type -AssemblyName System.Web

    $ParamCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty) 

    if ($primary_serial) {
        $ParamCollection.Add('primary_serial',$primary_serial)
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
        $integration_identifier
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

function Create-HuduAsset {
        param(
        $Token,
        $URL,
        $asset_name,
        $asset_fields,
        $company_id
    )

    $RequestParams = @{ 
        asset = @{fields=@[]}
    }
    if ($asset_name) {
        $RequestParams.asset.add('name',$asset_name)
    }
    
    if ($asset_fields -is [Array]) {
      foreach ($asset_fields as $field) {
        if ($field['asset_layout_field_id'] AND $field['value']) {
          $RequestParams.asset.fields.add(@{asset_layout_field_id=$field['asset_layout_field_id']; value=$field['value']})
        }
      }
    }

    #remove empty keys
    $RequestParams.GetEnumerator() | ? Value


    $EndPoint = "/api/v1/companies/$company_id/assets"


    $URL += $EndPoint
    
    return hudu_request -Token "$Token" -URL "$URL" -Method "POST" -Body $(ConvertTo-Json $RequestParams)
    
}

function Post-HuduCompany {
        param(
        $Token,
        $URL,
        $company_name,
        $company_nickname,
        $address_line_1,
        $address_line_2,
        $phone_number,
        $fax_number,
        $city,
        $state,
        $country_name,
        $zip,
        $website,
        $notes
    )


    $RequestParams = @{ 
        company = @{}
    }
    if ($company_name) {
        $RequestParams.company.add('name',$company_name)
    }
    if ($company_nickname) {
        $RequestParams.company.add('nickname',$company_nickname)
    }
    if ($address_line_1) {
        $RequestParams.company.add('address_line_1',$address_line_1)
    }
    if ($address_line_2) {
        $RequestParams.company.add('address_line_2',$address_line_2)
    }
    if ($city) {
        $RequestParams.company.add('city',$city)
    }
    if ($state) {
        $RequestParams.company.add('state',$state)
    }
    if ($zip) {
        $RequestParams.company.add('zip',$zip)
    }
    if ($country_name) {
        $RequestParams.company.add('country_name',$country_name)
    }
    
    if ($phone_number) {
        $RequestParams.company.add('phone_number',$phone_number)
    }
    
    if ($fax_number) {
        $RequestParams.company.add('fax_number',$fax_number)
    }
    if ($website) {
        $RequestParams.company.add('website',$website)
    }
    if ($notes) {
        $RequestParams.company.add('notes',$notes)
    }

    #remove empty keys
    $RequestParams.GetEnumerator() | ? Value


    $EndPoint = "/api/v1/companies"


    $URL += $EndPoint

    Write-Warning $URL

    return hudu_request -Token "$Token" -URL "$URL" -Method "POST" -Body $(ConvertTo-Json $RequestParams)
    
}

function Delete-HuduCompany {
        param(
        $Token,
        $URL,
        $company_id
    )

    $EndPoint = "api/v1/companies/$company_id"

    $URL += $EndPoint

    $json = hudu_request -Token "$Token" -URL "$URL" -Method "DELETE"

    $jsonObject = ConvertFrom-Json $json

    return $jsonObject

}
Export-ModuleMember -Function Get-HuduCompanies
Export-ModuleMember -Function Get-HuduAssets
Export-ModuleMember -Function Get-HuduCardLookup
Export-ModuleMember -Function Post-HuduCompany
Export-ModuleMember -Function Delete-HuduCompany
