import subprocess # needed for powershell function
import time
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

POWERSHELL_PATH = "powershell.exe"
# path to script or command(s) can be inserted directly
get_clipboard = "Get-Clipboard"
awsUpdate = "C:\\Users\\Almighty\\Documents\\terraform\\aws\\scripts\\awsUpdate.ps1"

# clear console function helpful when working through trial and error
def cls():
    os.system('cls')
    return None

def run_Powershell(script, *params):  # optional ps parameters can be used
    # Add ps path and execution policy settings to run script
    commandline_options = [POWERSHELL_PATH, '-ExecutionPolicy', 'Unrestricted', script]  
    # If there are multiple parameters append each one
    for param in params:
        commandline_options.append("'"+param+"'")
    process_result = subprocess.run(commandline_options, stdout = subprocess.PIPE, stderr = subprocess.PIPE, universal_newlines=True)
    #print(process_result.returncode)  # print return code of process  0 = success, non-zero = fail #! troubleshooting
    if process_result.returncode == 0:  # COMPARING RESULT
        message = "Success !"
        message = process_result.stdout
        print(process_result.stdout)      # PRINT STANDARD OUTPUT FROM POWERSHELL
    else:
        message = "Error Occurred !"
        print("Error Occurred!\nReturn Code " + str(process_result.returncode))
        print(process_result.stderr)      # PRINT STANDARD ERROR FROM POWERSHELL ( IF ANY OTHERWISE ITS NULL|NONE )
    return message

CHROMEDRIVER_PATH = "C:\Program Files (x86)\Google\chromedriver.exe"
chrome_options = webdriver.ChromeOptions()
# have to copy n paste the "user data" folder to a unique one otherwise they fight over each other
chrome_options.add_argument(r'user-data-dir=C:\\Users\\Almighty\\AppData\\Local\\Google\\Chrome\\Selenium Data')
chrome_options.add_argument(r'--profile-directory=Profile 2')
chrome_options.add_experimental_option('excludeSwitches', ['enable-logging']) # ignore dumb USB errors
driver = webdriver.Chrome(options=chrome_options, service=Service(CHROMEDRIVER_PATH))

driver.get("https://learn.acloud.guru/cloud-playground/cloud-sandboxes")
time.sleep(2)

# Open AWS Sandbox
try:
    start_AWS = WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="rc-tabs-0-panel-cloud-sandboxes"]/div[1]/div[2]/div/div/div/div/div/button/span')))
    start_AWS.click()
except:
    pass
    
try:
    # Access Key ID
    access_key_id_copy = WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, '//*[@id="rc-tabs-0-panel-cloud-sandboxes"]/div/div[1]/div[2]/div[3]/div[4]/div[2]/div')))
    access_key_id_copy.click()
    access_key_id = run_Powershell(get_clipboard)
    # Secret Access Key
    secret_access_key_copy = driver.find_element(By.XPATH, '//*[@id="rc-tabs-0-panel-cloud-sandboxes"]/div/div[1]/div[2]/div[3]/div[5]/div[2]/div')
    secret_access_key_copy.click()
    secret_access_key = run_Powershell(get_clipboard)
    # username_copy = driver.find_element(By.XPATH, '//*[@id="rc-tabs-0-panel-cloud-sandboxes"]/div/div[1]/div[2]/div[3]/div[1]/div[2]/div')
    # username_copy.click()
    # username = run_Powershell(get_clipboard)
    # pw_copy = driver.find_element(By.XPATH, '//*[@id="rc-tabs-0-panel-cloud-sandboxes"]/div/div[1]/div[2]/div[3]/div[2]/div[2]/div')
    # pw_copy.click()
    # pw = run_Powershell(get_clipboard)
    # # URL
    # url_copy = driver.find_element(By.XPATH, '//*[@id="rc-tabs-0-panel-cloud-sandboxes"]/div/div[1]/div[2]/div[3]/div[3]/div[2]/div')
    # url_copy.click()
    # url = run_Powershell(get_clipboard)
    print(run_Powershell(awsUpdate, access_key_id, secret_access_key))
except:
    print("There was an error starting the sandbox")
    driver.close()
finally:
    driver.close()