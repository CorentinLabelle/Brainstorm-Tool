classdef CellCreator

    methods (Static, Access = ?ProcessFactory)

        function processes = createCell(ctorHandle, input)

            m = size(input, 1);
            n = size(input, 2);
            processes = cell(m,n);
            for i = 1:m
                for j = 1:n
                    %processes{i,j} = ctorHandle(input(i,j));
                    processes{i,j} = ScalarCreator.createScalar(ctorHandle, input(i,j));
                end
            end

        end

    end

end