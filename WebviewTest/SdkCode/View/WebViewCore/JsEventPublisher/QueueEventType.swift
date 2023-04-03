//
//  QueueEventType.swift
//  WebviewTest
//
//  Created by Nitin Prakash on 22/03/23.
//

internal enum QueueEventType {
    case PUBLIC_KEY_CREATED
    case SIM_SUBSCRIPTION_ID_CHOSEN
    case LOAD_URL
    case PCI_FETCH_FAILED
    case YES_BANK_TOKEN_RECEIVED
    case YES_BANK_TOKEN_GENERATION_FAILED
    case SEND_SMS_SUCCESS
    case SEND_SMS_FAILED
    case PERMISSION_REQUEST_RESULT
    case PERSISTENT_STORAGE_FILE_LOADED
    case CUSTOMER_INITIALIZER_SET
    case FRAGMENT_RESUMED
    case DEVICE_BACK_BUTTON_PRESSED
}
