#Script Name: Nessus_Full_PCI_Parser.ps1
#Description: 
#   Use to only parse ".nessus" files for critical, high, medium, and low Nessus findings for PCI in-scope systems.
#   The output results in multiple CSV files containing the appripriate critical finding info, and
#   produces metrics useful for quantitative reporting.
# Written by: Will Armijo
# Created on: 02/12/2010

$time_taken = measure-command {
$Severity_Critical=0
$Severity_High=0
$Severity_Medium=0
$Severity_Low=0
$FN=0
$ScannedHostCount=0

$Quarter = Read-Host
$Month = Read-Host

#Remediation Tracking Reports - ***Update the directory paths to match your own environment***
$High_Remediation_Tracking = "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Findings\PCI\High_PCI_Results_{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".csv"
$Medium_Remediation_Tracking = "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Findings\PCI\Medium_PCI_Results_{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".csv"
$Low_Tracking = "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Findings\PCI\Low_PCI_Results_{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".csv"
$Master_Tracking = "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Remediation_Tracking\Master_PCI_Results_{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".csv"

#Scan Reports - ***Update the directory paths to match your own environment***
$Vuln_H_Detail_Report = "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Scan_Reports\PCI\High_PCI_Detail_Report_{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".doc"
$Vuln_M_Detail_Report = "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Scan_Reports\PCI\Medium_PCI_Detail_Report_{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".doc"
$Scan_Log = "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Findings\PCI\Nessus_Parse_Log_{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".log"

#Temporary file used for Host count comparisons
$Temp_Hostlist = "c:\temp\Temporary_Hostslist_{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".log"

#Headers for Remediation Tracking Reports
write-host   "CVSS `tSeverity `tHostname`tHost Location `tPluginID `tVulnerability Name `tPort & Service `tCVE ID(s) `tRT Ticket `tRemediation/Mitigation `tDate Remediated `tOwner"
write-output "CVSS `tSeverity `tHostname`tHost Location `tPluginID `tVulnerability Name `tPort & Service `tCVE ID(s) `tRT Ticket `tRemediation/Mitigation `tDate Remediated `tOwner" >> $High_Remediation_Tracking
write-output "CVSS `tSeverity `tHostname `tHost Location `tPluginID `tVulnerability Name `tPort & Service `tCVE ID(s) `tRT Ticket `tRemediation/Mitigation `tDate Remediated `tOwner" >> $Medium_Remediation_Tracking
write-output "CVSS `tSeverity `tHostname `tHost Location `tPluginID `tVulnerability Name `tPort & Service `tCVE ID(s) `tRT Ticket `tRemediation/Mitigation `tDate Remediated `tOwner" >> $Low_Tracking
write-output "CVSS `tSeverity `tHostname `tHost Location `tPluginID `tVulnerability Name `tPort & Service `tCVE ID(s) `tRT Ticket `tRemediation/Mitigation `tDate Remediated `tOwner" >> $Master_Tracking

# Actual Nessus file processing takes place here - ***Update the directory paths to match your own environment***
$nessFiles = (get-childitem "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Nessus_Scans\PCI\*")

foreach($nessFile in $nessFiles)
        {
            $FN++
        $File_Name = $nessFile.name
        
        $nessus_results = [xml] ( get-content "\\filesrv\it\Information Security\InternalVulnerabilityScans\2012\$Quarter\$Month\Nessus_Scans\PCI\$File_Name")
        
        write-host $ScannedHost in $nessus.NessusClientData_v2.Report.ReportHost[0]
        
            
                foreach ($ScannedHost in $nessus_results.NessusClientData_v2.Report.ReportHost)
                        {
                            
                            $Host_Name = $ScannedHost.Name
                            
                            write-host $Host_Name
                            
                            write-output $Host_Name >> $Temp_Hostlist
                                                                                                                               
                            foreach ($Item in $ScannedHost.ReportItem)
	                                {
                                            
                                        $Vuln_CVSS = $Item.cvss_base_score
                                        $Vuln_Name = $Item.pluginName
                                        $VUln_Descr = $Item.description
                                        $Vuln_Solution = $Item.solution
                                        $Vuln_ouput = $Item.plugin_output
                                        $Vuln_Exploitable = $Item.exploit_available
                                        $Vuln_CVE = $Item.cve
                                        $Vuln_PluginID = $Item.pluginID
                                        $Vuln_Port = $Item.port
                                        $Service = $Item.svc_name
                                                                                
                                   if($Vuln_CVSS -eq "10.0")
                                        { 
                                          $Severity_Critical++
                                          
                                          $CVSS_Severity = "Critical"
                        
                                            write-host "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name `t$File_Name `t$Vuln_PluginID `t$Vuln_Name  `t$Vuln_Port & $Service  `t$Vuln_CVE `t `t `t `t$Owner"
                                            write-output "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name  `t$File_Name `t$Vuln_PluginID `t$Vuln_Name  `t$Vuln_Port & $Service `t$Vuln_CVE  `t `t `t `t$Owner" >> $High_Remediation_Tracking
                                            write-output "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name  `t$File_Name `t$Vuln_PluginID `t$Vuln_Name `t$Vuln_Port & $Service  `t$Vuln_CVE  `t `t `t `t$Owner" >> $Master_Tracking
                                        
                                        
                                        #Detailed Report
                                        write-output "=======================" >> $Vuln_H_Detail_Report
                                        write-output "Ticket#: " >> $Vuln_H_Detail_Report
                                        write-output "Severity: `t$CVSS_Severity" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Hostname(s)/IP(s): `n$Host_Name" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Vulnerability Information: `n$Vuln_Name" >> $Vuln_H_Detail_Report
                                        write-output "Detected on: $Vuln_Port running $Service " >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Known Exploit?: $Vuln_Exploitable" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Description: `n$VUln_Descr" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Solution: `n$Vuln_Solution" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "CVE ID(s): `n$Vuln_CVE" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                        
                                        }  
                                   elseif($Vuln_CVSS -gt "6.9" -AND $Vuln_CVSS -le "9")
                                        { 
                                          $Severity_High++
                                          
                                          $CVSS_Severity = "High"
                        
                                            write-host "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name `t$File_Name `t$Vuln_PluginID `t$Vuln_Name  `t$Vuln_Port & $Service  `t$Vuln_CVE `t `t `t `t$Owner"
                                            write-output "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name  `t$File_Name `t$Vuln_PluginID `t$Vuln_Name  `t$Vuln_Port & $Service `t$Vuln_CVE  `t `t `t `t$Owner" >> $High_Remediation_Tracking
                                            write-output "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name  `t$File_Name `t$Vuln_PluginID `t$Vuln_Name `t$Vuln_Port & $Service  `t$Vuln_CVE  `t `t `t `t$Owner" >> $Master_Tracking
                                        
                                        
                                        #Detailed Report
                                        write-output "=======================" >> $Vuln_H_Detail_Report
                                        write-output "Ticket#: " >> $Vuln_H_Detail_Report
                                        write-output "Severity: `t$CVSS_Severity" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Hostname(s)/IP(s): `n$Host_Name" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Vulnerability Information: `n$Vuln_Name" >> $Vuln_H_Detail_Report
                                        write-output "Detected on: $Vuln_Port running $Service " >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Known Exploit?: $Vuln_Exploitable" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Description: `n$VUln_Descr" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Solution: `n$Vuln_Solution" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "CVE ID(s): `n$Vuln_CVE" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                        
                                        }  
                                 elseif($Vuln_CVSS -ge "4" -AND $Vuln_CVSS -lt "7")
                                        { 
                                        
                                        $Severity_Medium++
                                        $CVSS_Severity = "Medium"
                        
                                        write-host "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name  `t$File_Name `t$Vuln_PluginID `t$Vuln_Name `t$Vuln_Port & $Service `t$Vuln_CVE `t `t `t `t$Owner"    
                                        write-output "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name  `t$File_Name `t$Vuln_PluginID `t$Vuln_Port & $Service `t$Vuln_Name `t$Vuln_CVE `t `t `t `t$Owner" >> $Medium_Remediation_Tracking
                                        write-output "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name  `t$File_Name `t$Vuln_PluginID `t$Vuln_Name  `t$Vuln_Port & $Service `t$Vuln_CVE `t `t `t `t$Owner" >> $Master_Tracking
                                        
                                          
                                        
                                        #Detailed Report
                                        write-output "=======================" >> $Vuln_M_Detail_Report
                                        write-output "RT Ticket#: " >> $Vuln_M_Detail_Report
                                        write-output "Severity: `t$CVSS_Severity" >> $Vuln_M_Detail_Report
                                        write-output "" >> $Vuln_M_Detail_Report
                                        write-output "Hostname(s)/IP(s): `n$Host_Name" >> $Vuln_M_Detail_Report
                                        write-output "" >> $Vuln_H_Detail_Report
                                        write-output "Vulnerability Information: `n$Vuln_Name" >> $Vuln_M_Detail_Report
                                        write-output "Detected on: $Vuln_Port running $Service " >> $Vuln_M_Detail_Report
                                        write-output "" >> $Vuln_M_Detail_Report
                                        write-output "Known Exploit?: $Vuln_Exploitable" >> $Vuln_M_Detail_Report
                                        write-output "" >> $Vuln_M_Detail_Report
                                        write-output "Description: `n$VUln_Descr" >> $Vuln_M_Detail_Report
                                        write-output "" >> $Vuln_M_Detail_Report
                                        write-output "Solution: `n$Vuln_Solution" >> $Vuln_M_Detail_Report
                                        write-output "" >> $Vuln_M_Detail_Report
                                        write-output "CVE ID(s): `n$Vuln_CVE" >> $Vuln_M_Detail_Report
                                        write-output "" >> $Vuln_M_Detail_Report
                                        write-output "" >> $Vuln_M_Detail_Report
                                        }
                                  elseif($Vuln_CVSS -lt "4")
                                        {
                                            $Severity_Low++
                                            write-output "$Vuln_CVSS `t$CVSS_Severity `t$Host_Name `t$File_Name `t$Vuln_PluginID `t$Vuln_Name  `t$Vuln_Port & $Service `t$Vuln_Exploitable " >> $Low_Tracking
                                           
                                        }
                                    
                                    $CVSS_Severity = ""
                                    $Vuln_CVSS = ""
                                    }
                        }
        
        
        }

}

$Days = $time_taken.Days
$Hours = $time_taken.Hours
$Minutes = $time_taken.Minutes
$Seconds = $time_taken.Seconds

$Unique_Host_Array = get-content $Temp_Hostlist | sort-object | Get-Unique
$ScannedHostCount = $Unique_Host_Array.count


write-host "=================Parsing Metrics=================="
write-host "Time taken to Parse all PCI Nessus Scan Files:"
write-host "Days: $Days"
write-host "Hours: $Hours"
write-host "Minutes: $Minutes"
write-host "Seconds: $Seconds"


write-host ""
write-host ""
write-host "===================================================="
write-host "Compliance Metrics"
write-host ""
write-host "===================================================="
write-host ""
write-host "Critcal findings: $Severity_Critical"
write-host "High findings: $Severity_High"
write-host "Medium findings: $Severity_Medium"
write-host "==============================================="
write-Host "Total Number of Hosts Scanned: $ScannedHostCount"



write-output  "=================Parsing Metrics==================" >> $Scan_Log
write-output  "Time taken to Parse all PCI Nessus Scan Files:" >> $Scan_Log
write-output  "Days: $Days" >> $Scan_Log
write-output  "Hours: $Hours" >> $Scan_Log
write-output  "Minutes: $Minutes" >> $Scan_Log
write-output  "Seconds: $Seconds" >> $Scan_Log


write-output "====================================================" >> $Scan_Log
write-output "Compliance Metrics" >> $Scan_Log
write-output "" >> $Scan_Log
write-output "====================================================" >> $Scan_Log
write-output "" >> $Scan_Log
write-output "Critcal findings: $Severity_Critical" >> $Scan_Log
write-output "High findings: $Severity_High" >> $Scan_Log
write-output "Medium findings: $Severity_Medium" >> $Scan_Log
write-output "Low/Informational findings: $Severity_Low" >> $Scan_Log
write-output  "================================================" >> $Scan_Log
write-output "" >> $Scan_Log
write-output  "Total Number of Hosts Scanned: $ScannedHostCount" >> $Scan_Log


 function sendMail{

     Write-Host "Sending Email Notification"

     #SMTP server name - ***Change to match your email server
     $smtpServer = "smtpserver"

     #Creating a Mail object
     $msg = new-object Net.Mail.MailMessage

     #Creating SMTP server object
     $smtp = new-object Net.Mail.SmtpClient($smtpServer)

     #Email structure - ***Update email address
     $msg.From = "NessusReport@<domain>.com"
     $msg.To.Add("<Receiving Email Address>")
     $msg.subject = "As of {0:MM-dd-yyyy-HH:mm}" -f (Get-Date) + " Nesus Parsing is complete."
     $msg.body = "All PCI Scan Results have been parsed for $Month
     
     Please review the following Detailed Vulnerability Reports:
     $Vuln_H_Detail_Report
     $Vuln_M_Detail_Report
     
     Master tracking Document Lists all High and Medium Findings. This will be used for tracking rememdiation efforts:
     $Master_Tracking
     
     ====================================================
     Compliance Metrics
        
        Critcal findings: $Severity_Critical
        High findings: $Severity_High
        Medium findings: $Severity_Medium
        Low/Informational findings: $Severity_Low
     ====================================================   
        Total Number of Hosts Scanned: $ScannedHostCount"
    
     #Sending email
     $smtp.Send($msg)
 
}

#Calling function
sendMail

Remove-Item $Temp_Hostlist