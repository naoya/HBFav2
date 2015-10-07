class ActionRequestHandler
  attr_accessor :extensionContext

  def beginRequestWithExtensionContext(context)
    self.extensionContext = context;
    
    # Find the item containing the results from the JavaScript preprocessing.
    context.inputItems.each do |item|
      item.attachments.each do |itemProvider|
        if itemProvider.hasItemConformingToTypeIdentifier(KUTTypePropertyList)
          itemProvider.loadItemForTypeIdentifier(KUTTypePropertyList, options:nil, completionHandler:proc { |dictionary, error|
            NSOperationQueue.mainQueue.addOperationWithBlock(proc {
              self.doneWithResults({"dummy_key" => "dummy_value"})
            })
          })
          return
        end
      end
    end
    
    # We did not find anything
    self.doneWithResults(nil)
  end

  def doneWithResults(resultsForJavaScriptFinalize)
    if resultsForJavaScriptFinalize
      resultsDictionary = { NSExtensionJavaScriptFinalizeArgumentKey => resultsForJavaScriptFinalize }
      resultsProvider = NSItemProvider.alloc.initWithItem(resultsDictionary, typeIdentifier:KUTTypePropertyList)
      resultsItem = NSExtensionItem.alloc.init
      resultsItem.attachments = [resultsProvider]
      # Signal that we're complete, returning our results.
      self.extensionContext.completeRequestReturningItems([resultsItem], completionHandler:nil)
    else
      # We still need to signal that we're done even if we have nothing to
      # pass back.
      self.extensionContext.completeRequestReturningItems([], completionHandler:nil)
    end
    
    # Don't hold on to this after we finished with it.
    self.extensionContext = nil
  end
end
