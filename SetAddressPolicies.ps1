###############################################################################################################################################################################
###                                                                                                           																###
###		.INFORMATIONS																																						###
###  	Script by Drago Petrovic -                                                                            																###
###     Technical Blog -               https://msb365.abstergo.ch                                               																###
###     GitHub Repository -            https://github.com/MSB365                                          	  																###
###     Webpage -                                                                  																							###
###     Xing:				   		   https://www.xing.com/profile/Drago_Petrovic																							###
###     LinkedIn:					   https://www.linkedin.com/in/drago-petrovic-86075730																					###
###																																											###
###		.VERSION																																							###
###     Version 1.0 - 02/07/2016                                                                              																###
###     Version 2.0 - 23/06/2017                                                                              																###
###     Revision -                                                                                            																###
###                                                                                                           																### 
###               v1.0 - Initial script										                                  																###
###               v2.0 - Making it more Userfriendli				                                          																###
###																																											###
###																																											###
###		.SYNOPSIS																																							###
###		SetAddressPolicies.ps1																																				###
###																																											###
###		.DESCRIPTION																																						###
###		Script to Email address Policies							.																										###
###																																											###
###		.PARAMETER																																							###
###																																											###
###																																											###
###		.EXAMPLE																																							###
###		.\SetAddressPolicies.ps1																																			###
###																																											###
###		.NOTES																																								###
###		Ensure you update the script with your tenant name and username																										###
###		Your username is in the Exchange Online section for Get-Credential																									### 	
###		The tenant name is used in the Exchange Online section for Get-Credential																							###
###		The tenant name is used in the SharePoint Online section for SharePoint connection URL																				###
###                                                                                                           																###  	
###     .COPIRIGHT                                                            																								###
###		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 					###
###		to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 					###
###		and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:							###
###																																											###
###		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.										###
###																																											###
###		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 				###
###		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 		###
###		WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.			###
###                 																																						###
###                                                																															###
###                                                                                                           																###
###                                                                                                           																###
###############################################################################################################################################################################
#
Write-Host "!!! with great power comes great responsibility !!!" -ForegroundColor magenta -Verbose
#
#####################################################################################################

# Variables
Write-Host "Enter your Domains to create the Mail address Policies" -ForegroundColor yellow
$Name1 = Read-Host "Enter the Name you wanna use for the internal Policy e.g. fabrikam-local"
$Dom1 = Read-Host "Enter your internal Exchange Domain e.g. fabrikam.local"
$Name2 = Read-Host "Enter the Name you wanna use for primary external Domain Policy e.g. fabrikam-extern"
$Dom2 = Read-Host "Enter your primary external Exchange Domain e.g. fabrikam.com"
$LocPat2 = Read-Host "Enter the Member Group OU e.g. OU=FABRIKAM,OU=CUSTOMERS,DC=fabrikam,DC=local"
$Name3 = Read-Host "Enter the Name you wanna use for primary Accepted Domain Policy e.g. contoso-extern"
$Dom3 = Read-Host "Enter your first Accepted Exchange Domain e.g. contoso.com"
$LocPat3 = Read-Host "Enter the Member Group OU e.g. OU=CONTOSO,OU=CUSTOMERS,DC=fabrikam,DC=local"
$Name4 = Read-Host "Enter the Name you wanna use for secondary Accepted Domain Policy e.g. abstergo-extern"
$Dom4 = Read-Host "Enter your second Accepted Exchange Domain e.g. abstergo.ch"
$LocPat4 = Read-Host "Enter the Member Group OU e.g. OU=ABSTERGO,OU=CUSTOMERS,DC=fabrikam,DC=local"

#####################################################################################################
### Script
# Create Mailaddress Policy for Resources
Write-Host "Creating the 1st Mailaddress Policy $Name1 for Resources..." -ForegroundColor cyan
New-EmailAddressPolicy -Name $Name1 -EnabledPrimarySMTPAddressTemplate 'SMTP:alias@$Dom1' -IncludedRecipients 'Resources' -Priority 1
Write-Host "Done!" -ForegroundColor green

# Create primary Mailaddress Policy
Write-Host "Creating the 2nd Mailaddress Policy $Name2 for the Domain $Dom2 ..." -ForegroundColor cyan
New-EmailAddressPolicy -Name $Name2 -EnabledPrimarySMTPAddressTemplate 'SMTP:%g.%i.%s@$Dom2' -RecipientFilter {((MemberOfGroup -eq $LocPat2) -and (RecipientType -eq 'UserMailbox'))} -Priority 2
Set-EmailAddressPolicy $Name2 -EnabledEmailAddressTemplates SMTP:%g.%i.%s@$Dom2,smtp:%g.%i.%s@$Dom1,smtp:%1g.%s@$Dom1,smtp:alias@$Dom1
Write-Host "Done!" -ForegroundColor green

# Create first Accepted Domain Mailaddress Policy
Write-Host "Creating the 3rd Mailaddress Policy $Name3 for the Accepted Domain $Dom3 ..." -ForegroundColor cyan
New-EmailAddressPolicy -Name $Name3 -EnabledPrimarySMTPAddressTemplate 'SMTP:%g.%i.%s@$Dom3' -RecipientFilter {((MemberOfGroup -eq $LocPat3) -and (RecipientType -eq 'UserMailbox'))} -Priority 3
Set-EmailAddressPolicy $Name3 -EnabledEmailAddressTemplates SMTP:%g.%i.%s@$Dom3,smtp:%g.%i.%s@$Dom1,smtp:%1g.%s@$Dom1,smtp:alias@$Dom1
Write-Host "Done!" -ForegroundColor green

# Create first Accepted Domain Mailaddress Policy
Write-Host "Creating the 4th Mailaddress Policy $Name4 for the Accepted Domain $Dom4 ..." -ForegroundColor cyan
New-EmailAddressPolicy -Name $Name4 -EnabledPrimarySMTPAddressTemplate 'SMTP:%g.%i.%s@certum.ch' -RecipientFilter {((MemberOfGroup -eq $LocPat4) -and (RecipientType -eq 'UserMailbox'))} -Priority 4
Set-EmailAddressPolicy $Name4 -EnabledEmailAddressTemplates SMTP:%g.%i.%s@$Dom4,smtp:%g.%i.%s@$Dom1,smtp:%1g.%s@$Dom1,smtp:alias@$Dom1
Write-Host "Done!" -ForegroundColor green

# Enable all Policies
Write-Host "Enable all Address Policies..." -ForegroundColor cyan
Get-EmailAddressPolicy $Name1 | Update-EmailAddressPolicy
Get-EmailAddressPolicy $Name2 | Update-EmailAddressPolicy
Get-EmailAddressPolicy $Name3 | Update-EmailAddressPolicy
Get-EmailAddressPolicy $Name4 | Update-EmailAddressPolicy
Write-Host "Done!" -ForegroundColor green

# Information
Write-Host "All Mailaddress Policies are created! See the Summary below..." -ForegroundColor magenta -Verbose
Get-EmailAddressPolicy




























