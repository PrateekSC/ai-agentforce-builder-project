/**
 * Controller for generating account summaries with the Account Summary prompt template.
 */
public with sharing class AccountPromptController {
    /**
     * Generates an account summary by invoking the Account Summary prompt template.
     *
     * @param accountId The ID of the account to summarize.
     * @return The generated account summary text.
     */
    @AuraEnabled
    public static String generateAccountSummary(Id accountId) {

        Account acc = [
            SELECT Id,
                   Name,
                   Industry,
                   AnnualRevenue,
                   Rating
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        ConnectApi.WrappedValue accountValue =
            new ConnectApi.WrappedValue();

        // Even for Object data types, the ConnectApi framework requires this exact map structure:
        Map<String, String> recordIdMap = new Map<String, String>();
        recordIdMap.put('id', accountId);
        accountValue.value = recordIdMap;

        Map<String, ConnectApi.WrappedValue> inputParams =
            new Map<String, ConnectApi.WrappedValue>();

        inputParams.put(
            'Input:Account',
            accountValue
        );

        ConnectApi.EinsteinPromptTemplateGenerationsInput request =
            new ConnectApi.EinsteinPromptTemplateGenerationsInput();

        request.inputParams = inputParams;
        request.isPreview = false;

        request.additionalConfig =
            new ConnectApi.EinsteinLlmAdditionalConfigInput();

        request.additionalConfig.applicationName =
            'PromptTemplateGenerationsInvocable';

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response =
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                'Account_Summary_Template',
                request
            );

        return response.generations[0].text;
    }
}