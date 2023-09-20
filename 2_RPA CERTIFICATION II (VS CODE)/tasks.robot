*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${FALSE}
Library     RPA.Tables
Library     RPA.HTTP
Library     RPA.PDF
Library     RPA.Archive
Library     RPA.FileSystem


*** Tasks ***
procedura completa
    aprire browser, download, ordinare e salvare PDF-screenshot
    Archive output Pdf
    Close Browser


*** Keywords ***
aprire browser, download, ordinare e salvare PDF-screenshot
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True
    inserimento ordini e salvataggio PDF
    chiudi finestra temporanea

inserimento ordini e salvataggio PDF
    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${riga}    IN    @{orders}
        inserimento per un robot con salvataggio PDF    ${riga}
    END
    # ${riga} è una variabile locale, quindi se voglio urilizzarla per il PDF,
    # i comandi relativi a quest'ultimo devo metterli dove ${riga} è dichiarata

inserimento per un robot con salvataggio PDF
    [Arguments]    ${riga}
    chiudi finestra temporanea
    Wait Until Element Is Visible    xpath=//select[@name="head"]
    Select From List By Value    id:head    ${riga}[Head]
    Click Element    xpath=//input[@id="id-body-${riga}[Body]"]
    Input Text    xpath=//input[@placeholder="Enter the part number for the legs"]    ${riga}[Legs]
    Input Text    xpath=//input[@id="address"]    ${riga}[Address]
    Wait Until Keyword Succeeds    10x    0.5s    Preview robot
    # aspetta per il range di tempo inserito e poi ci rispova tante volte quanto "10x"
    Wait Until Keyword Succeeds    10x    0.5s    Submit order
    Wait Until Element Is Visible    xpath=//button[@id="order-another"]
    salvare ordine come PDF-screenshot-unire    ${riga}[Order number]
    Click Element    //button[@id="order-another"]

chiudi finestra temporanea
    Wait Until Element Is Visible    xpath=//button[@class="btn btn-dark"]
    Click Button    xpath=//button[@class="btn btn-dark"]

Preview robot
    Click Element    id:preview
    Wait Until Element Is Visible    xpath=//img[@alt="Head"]
    Wait Until Element Is Visible    xpath=//img[@alt="Body"]
    Wait Until Element Is Visible    xpath=//img[@alt="Legs"]

Submit order
    Click Element    id:order
    Wait Until Element Is Visible    id:order-completion    0.5s

salvare ordine come PDF-screenshot-unire
    [Arguments]    ${order_number}
    # secondo argomento: nome degli attributi che vogliamo ottenere
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML

    ${pdf}=    Html To Pdf    ${receipt_html}
    ...    ${OUTPUT_DIR}${/}receipts${/}order_${order_number}.pdf
    # come secondo argomento si può dare il percorso dove salvare il file

    ${screenshot}=    Screenshot    css:div#robot-preview-image
    ...    ${OUTPUT_DIR}${/}images${/}robot_image_${order_number}.png
    ${files}=    Create List    ${screenshot}:align=center
    Open Pdf    ${OUTPUT_DIR}${/}receipts${/}order_${order_number}.pdf
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}receipts${/}order_${order_number}.pdf    append:${True}
    Close Pdf    ${OUTPUT_DIR}${/}receipts${/}order_${order_number}.pdf

Archive output Pdf
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}/orders.zip
