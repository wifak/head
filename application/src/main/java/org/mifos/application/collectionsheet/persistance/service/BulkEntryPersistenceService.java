/*
 * Copyright (c) 2005-2009 Grameen Foundation USA
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 *
 * See also http://www.apache.org/licenses/LICENSE-2.0.html for an
 * explanation of the license and how it is applied.
 */

package org.mifos.application.collectionsheet.persistance.service;

import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.mifos.application.accounts.business.AccountActionDateEntity;
import org.mifos.application.accounts.business.AccountBO;
import org.mifos.application.accounts.loan.persistance.LoanPersistence;
import org.mifos.application.accounts.loan.persistance.StandardClientAttendanceDao;
import org.mifos.application.accounts.savings.business.SavingsBO;
import org.mifos.application.accounts.savings.persistence.SavingsPersistence;
import org.mifos.application.accounts.util.helpers.AccountTypes;
import org.mifos.application.collectionsheet.business.CollectionSheetEntryAccountFeeActionView;
import org.mifos.application.collectionsheet.business.CollectionSheetEntryInstallmentView;
import org.mifos.application.collectionsheet.persistence.BulkEntryPersistence;
import org.mifos.application.collectionsheet.util.helpers.BulkEntryCache;
import org.mifos.application.customer.business.CustomerBO;
import org.mifos.application.customer.client.business.service.ClientAttendanceDto;
import org.mifos.application.customer.client.business.service.ClientService;
import org.mifos.application.customer.client.business.service.StandardClientService;
import org.mifos.application.customer.persistence.CustomerPersistence;
import org.mifos.application.personnel.business.PersonnelBO;
import org.mifos.application.personnel.persistence.PersonnelPersistence;
import org.mifos.framework.exceptions.PersistenceException;
import org.mifos.framework.exceptions.ServiceException;
import org.mifos.framework.util.helpers.DateUtils;

/**
 * This class's reponsibility is to handle the {@link BulkEntryCache}.
 * 
 * FIXME - keithw - remove class.
 * 
 * @deprecated - do not use - keithw. marked for delete post collection sheet
 *             refactor.
 */
@Deprecated
public class BulkEntryPersistenceService {

    private final BulkEntryCache bulkEntryCache = new BulkEntryCache();

    public List<CollectionSheetEntryInstallmentView> getBulkEntryActionView(Date meetingDate, String searchString,
            Short officeId, AccountTypes accountType) throws PersistenceException {
        return new BulkEntryPersistence().getBulkEntryActionView(meetingDate, searchString, officeId, accountType);

    }

    public List<CollectionSheetEntryAccountFeeActionView> getBulkEntryFeeActionView(Date meetingDate,
            String searchString, Short officeId, AccountTypes accountType) throws PersistenceException {
        return new BulkEntryPersistence().getBulkEntryFeeActionView(meetingDate, searchString, officeId, accountType);
    }

    public List<ClientAttendanceDto> getClientAttendance(Date meetingDate, Short officeId) throws PersistenceException {
        ClientService clientService = new StandardClientService();
        clientService.setClientAttendanceDao(new StandardClientAttendanceDao());
        try {
            return clientService.getClientAttendanceList(meetingDate, officeId);
        } catch (ServiceException e) {
            throw new PersistenceException(e);
        }
    }

    public AccountBO getCustomerAccountWithAccountActionsInitialized(Integer accountId) throws PersistenceException {
        return new CustomerPersistence().getCustomerAccountWithAccountActionsInitialized(accountId);
    }

    public AccountBO getSavingsAccountWithAccountActionsInitialized(Integer accountId) throws PersistenceException {
        if (!bulkEntryCache.isAccountPresent(accountId)) {
            AccountBO account;
            account = new SavingsPersistence().getSavingsAccountWithAccountActionsInitialized(accountId);
            bulkEntryCache.addAccount(accountId, account);
            Set<AccountActionDateEntity> accountActionDates = account.getAccountActionDates();
            for (Iterator<AccountActionDateEntity> iter = accountActionDates.iterator(); iter.hasNext();) {
                AccountActionDateEntity actionDate = iter.next();
                actionDate.getCustomer().getCustomerId();
                if (actionDate.isPaid() || actionDate.compareDate(DateUtils.getCurrentDateWithoutTimeStamp()) > 0) {
                    iter.remove();
                }
            }
        }
        SavingsBO savings = (SavingsBO) bulkEntryCache.getAccount(accountId);
        savings.setAccountPayments(null);
        savings.setSavingsActivityDetails(null);
        return savings;
    }

    public AccountBO getLoanAccountWithAccountActionsInitialized(Integer accountId) throws PersistenceException {
        return new LoanPersistence().getLoanAccountWithAccountActionsInitialized(accountId);
    }

    public CustomerBO getCustomer(Integer customerId) throws PersistenceException {
        if (!bulkEntryCache.isCustomerPresent(customerId)) {
            CustomerBO customer = new CustomerPersistence().getCustomer(customerId);
            bulkEntryCache.addCustomer(customerId, customer);
        }
        return bulkEntryCache.getCustomer(customerId);
    }

    public PersonnelBO getPersonnel(Short personnelId) throws PersistenceException {
        if (!bulkEntryCache.isPersonnelPresent(personnelId)) {
            PersonnelBO personnel = new PersonnelPersistence().getPersonnel(personnelId);
            bulkEntryCache.addPersonnel(personnelId, personnel);
        }
        return bulkEntryCache.getPersonnel(personnelId);
    }

}
