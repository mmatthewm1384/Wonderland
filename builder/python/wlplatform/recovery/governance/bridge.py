from .approval import ApprovalDecision


class GovernanceBridge:


    def approve(
        self,
        request,
        approver,
        reason
    ):

        return ApprovalDecision(
            transaction_id=request.transaction_id,
            decision="APPROVED",
            approver=approver,
            reason=reason
        )


    def reject(
        self,
        request,
        approver,
        reason
    ):

        return ApprovalDecision(
            transaction_id=request.transaction_id,
            decision="REJECTED",
            approver=approver,
            reason=reason
        )
